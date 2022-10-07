# frozen_string_literal: true

RSpec.describe Induction::TransferAndContinueExistingProgramme, :with_default_schedules do
  describe "#call" do
    let(:lead_provider)   { create(:cpd_lead_provider, :with_lead_provider, name: "Provider 1").lead_provider }
    let(:lead_provider_2) { create(:cpd_lead_provider, :with_lead_provider, name: "Provider 2").lead_provider }
    let(:school_1)        { create(:school, name: "Transferring From School") }
    let(:school_2)        { create(:school, name: "Transferring To School") }
    let(:school_cohort_1) { create(:school_cohort, :fip, :with_induction_programme, school: school_1, lead_provider:) }
    let(:school_cohort_2) { create(:school_cohort, :fip, :with_induction_programme, school: school_2, lead_provider: lead_provider_2) }
    let(:participant_profile)  { create(:ect,    school_cohort: school_cohort_1, lead_provider:) }
    let!(:mentor_profile_1)    { create(:mentor, school_cohort: school_cohort_1, lead_provider:) }
    let!(:mentor_profile_2)    { create(:mentor, school_cohort: school_cohort_2, lead_provider: lead_provider_2) }
    let(:start_date)           { 1.week.from_now }
    let(:end_date)             { 1.week.ago }
    let(:new_email_address)    { "hank.shanklin@new-school.example.com" }

    let(:new_induction_programme) { school_cohort_2.induction_programmes.order(:created_at).last }
    let(:new_partnership)         { school_2.partnerships.order(:created_at).last }
    let(:new_induction_record)    { participant_profile.induction_records.latest }

    subject(:service) { described_class }

    let(:service_call) do
      service.call(school: school_2,
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

    it "creates an induction programme at the transferring in school" do
      expect { service_call }.to change { school_cohort_2.induction_programmes.count }.by 1
    end

    it "creates an induction record for the new participant" do
      expect { service_call }.to change { participant_profile.induction_records.count }.by 1
    end

    context "when the original programme is a FIP" do
      it "creates a relationship partnership at the transferring in school" do
        expect { service_call }.to change { school_2.partnerships.relationships.count }.by 1
      end

      it "adds the new relationship to the new induction programme" do
        service_call
        expect(new_induction_programme.partnership).to eq new_partnership
      end
    end

    context "when a matching programme already exists in the cohort" do
      let(:induction_programme) { school_cohort_2.induction_programmes.first }

      before do
        partnership_2 = school_cohort_1.induction_programmes.first.partnership.dup
        partnership_2.school = school_cohort_2.school
        partnership_2.save!
        induction_programme.update!(partnership: partnership_2)
      end

      it "does not create a new programme" do
        expect { service_call }.not_to change { school_cohort_2.induction_programmes.count }
      end

      it "enrols the participant in the matching programme" do
        service_call
        expect(participant_profile.induction_records.latest.induction_programme).to eq induction_programme
      end
    end

    context "when the original programme is a CIP" do
      let(:core_induction_programme) { create(:core_induction_programme, name: "Super Materials") }
      let(:school_cohort_1) { create(:school_cohort, :cip, :with_induction_programme, school: school_1, core_induction_programme:) }

      it "adds the materials to the new induction programme" do
        service_call
        expect(new_induction_programme.core_induction_programme).to eq core_induction_programme
      end
    end

    context "record details" do
      before { service_call }

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
      let(:service_call) { service.call(school: school_2, participant_profile:) }

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
                     school: school_2,
                     email: new_email_address,
                     start_date:,
                     end_date:)
      end
    end
  end
end
