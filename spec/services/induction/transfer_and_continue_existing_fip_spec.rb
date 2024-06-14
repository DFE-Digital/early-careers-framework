# frozen_string_literal: true

RSpec.describe Induction::TransferAndContinueExistingFip do
  describe "#call" do
    let(:lead_provider) { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
    let(:school_1) { create(:school, name: "Transferring From School") }
    let(:school_2) { create(:school, name: "Transferring To School") }
    let(:school_cohort_1) { create(:school_cohort, :fip, :with_induction_programme, school: school_1, lead_provider:) }
    let(:school_cohort_2) { create(:school_cohort, :fip, :with_induction_programme, school: school_2, lead_provider:) }
    let(:participant_profile) { create(:ect, school_cohort: school_cohort_1, lead_provider:) }
    let!(:mentor_profile_1) { create(:mentor, school_cohort: school_cohort_1, lead_provider:) }
    let!(:mentor_profile_2) { create(:mentor, school_cohort: school_cohort_2, lead_provider:) }
    let(:start_date) { 1.week.from_now }
    let(:end_date) { 1.week.ago }
    let(:new_email_address) { "hank.shanklin@new-school.example.com" }

    let(:new_induction_programme) { school_cohort_2.induction_programmes.order(:created_at).last }
    let(:new_partnership) { school_2.partnerships.order(:created_at).last }
    let(:new_induction_record) { participant_profile.induction_records.latest }

    subject(:service) { described_class }

    let(:service_call) do
      service.call(school_cohort: school_cohort_2,
                   participant_profile:,
                   email: new_email_address,
                   start_date:,
                   end_date:,
                   mentor_profile: mentor_profile_2)
    end

    let!(:original_induction) { participant_profile.reload.induction_records.order(created_at: :asc).first }

    it "creates a new identity with the given email" do
      expect { service_call }.to change { participant_profile.user.participant_identities.count }.by 1
    end

    it "creates a relationship partnership at the transferring in school" do
      expect { service_call }.to change { school_2.partnerships.relationships.count }.by 1
    end

    it "creates an induction programme at the transferring in school" do
      expect { service_call }.to change { school_cohort_2.induction_programmes.count }.by 1
    end

    it "creates an induction record for the new participant" do
      expect { service_call }.to change { participant_profile.induction_records.count }.by 1
    end

    context "when the participant is eligible to be moved from a frozen cohort to the target one" do
      before do
        allow(participant_profile).to receive(:eligible_to_change_cohort_and_continue_training?)
                                        .with(cohort: school_cohort_2.cohort)
                                        .and_return(true)
        service_call
      end

      it "flags the participant as changed for that reason" do
        expect(participant_profile).to be_cohort_changed_after_payments_frozen
      end
    end

    context "when the participant is not eligible to be moved from a frozen cohort to the target one" do
      before do
        allow(participant_profile).to receive(:eligible_to_change_cohort_and_continue_training?)
                                        .with(cohort: school_cohort_2.cohort)
                                        .and_return(false)
        service_call
      end

      it "flag the participant as not changed for that reason" do
        expect(participant_profile).not_to be_cohort_changed_after_payments_frozen
      end
    end

    context "record details" do
      before { service_call }

      it "adds the new relationship to the new induction programme" do
        expect(new_induction_programme.partnership).to eq new_partnership
      end

      it "updates the previous induction record to leaving status" do
        expect(original_induction.reload).to be_leaving_induction_status
        expect(original_induction.end_date).to be_within(1.second).of end_date
      end

      it "enrols the participant in the new programme" do
        expect(new_induction_record.induction_programme).to eq new_induction_programme
        expect(new_induction_record).to be_active_induction_status
        expect(new_induction_record.start_date).to be_within(1.second).of start_date
      end

      it "assigns the specified mentor to the induction" do
        expect(new_induction_record.mentor_profile).to eq mentor_profile_2
      end

      it "assigns the preferred_identity to the induction" do
        expect(new_induction_record.preferred_identity.email).to eq new_email_address
      end
    end

    context "without optional params" do
      let(:service_call) { service.call(school_cohort: school_cohort_2, participant_profile:) }

      before { service_call }

      it "uses the existing participant identity" do
        expect(new_induction_record.preferred_identity).to eq participant_profile.participant_identity
      end

      it "sets the end date on the previous induction as the current time" do
        expect(original_induction.reload.end_date).to be_within(1.second).of Time.zone.now
      end
    end

    context "when the participant is a mentor" do
      before do
        Mentors::AddToSchool.call(mentor_profile: mentor_profile_1, school: school_cohort_1.school)
      end

      it "calls the Mentors::ChangeSchool service" do
        expect(Mentors::ChangeSchool).to receive(:call).with(mentor_profile: mentor_profile_1,
                                                             from_school: school_cohort_1.school,
                                                             to_school: school_cohort_2.school,
                                                             remove_on_date: start_date,
                                                             preferred_email: new_email_address)

        service.call(participant_profile: mentor_profile_1,
                     school_cohort: school_cohort_2,
                     email: new_email_address,
                     start_date:,
                     end_date:)
      end
    end

    context "when there is an existing active partnership at the school cohort for the participant's current LP/DP" do
      let!(:partnership) do
        create(:partnership,
               school: school_2,
               cohort: school_cohort_2.cohort,
               lead_provider: original_induction.lead_provider,
               delivery_partner: original_induction.delivery_partner)
      end

      it "do not create a new partnership at the transferring in school" do
        expect { service_call }.not_to change { school_2.partnerships.count }.from(2)
      end

      it "create a new induction_programme at the transferring in school" do
        expect { service_call }.to change { school_cohort_2.induction_programmes.count }.from(1).to(2)
      end

      it "enrols the participant in the new programme" do
        service_call

        expect(new_induction_record.induction_programme.partnership).to eq(partnership)
      end
    end

    context "when there is an existing induction programme at the school cohort for the participant's current LP/DP" do
      let!(:partnership) do
        create(:partnership,
               school: school_2,
               cohort: school_cohort_2.cohort,
               lead_provider: original_induction.lead_provider,
               delivery_partner: original_induction.delivery_partner)
      end

      let!(:induction_programme) do
        create(:induction_programme, :fip, school_cohort: school_cohort_2, partnership:)
      end

      it "don't create a new partnership at the transferring in school" do
        expect { service_call }.not_to change { school_2.partnerships.count }.from(2)
      end

      it "don't create a new induction_programme at the transferring in school" do
        expect { service_call }.not_to change { school_cohort_2.induction_programmes.count }.from(2)
      end

      it "enrols the participant in the new programme" do
        service_call

        expect(new_induction_record.induction_programme).to eq(induction_programme)
      end
    end
  end
end
