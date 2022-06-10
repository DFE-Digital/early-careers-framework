# frozen_string_literal: true

RSpec.describe Induction::TransferToSchoolsProgramme, :with_default_schedules do
  describe "#call" do
    let(:lead_provider_1)         { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
    let(:lead_provider_2)         { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
    let(:school_cohort_1)         { create(:school_cohort, :fip, :with_induction_programme, lead_provider: lead_provider_1) }
    let(:school_cohort_2)         { create(:school_cohort, :fip, :with_induction_programme, lead_provider: lead_provider_2) }
    let!(:induction_programme_2)  { school_cohort_2.induction_programmes.first }
    let!(:mentor_profile_1)       { create(:mentor, school_cohort: school_cohort_1, lead_provider: lead_provider_1) }
    let!(:mentor_profile_2)       { create(:mentor, school_cohort: school_cohort_2, lead_provider: lead_provider_2) }
    let(:participant_profile)     { create(:ect, school_cohort: school_cohort_1, lead_provider: lead_provider_1, mentor_profile_id: mentor_profile_1.id) }
    let(:start_date)              { 1.week.from_now }
    let(:end_date)                { 1.week.ago }
    let(:new_email_address)       { "peter.bonetti@new-school.example.com" }
    let(:new_induction_programme) { school_cohort_2.induction_programmes.order(:created_at).last }

    subject(:service) { described_class }

    let(:service_call) do
      service.call(participant_profile:,
                   induction_programme: induction_programme_2,
                   email: new_email_address,
                   start_date:,
                   end_date:,
                   mentor_profile: mentor_profile_2)
    end

    let!(:original_induction) { participant_profile.current_induction_record }

    it "creates a new identity with the given email" do
      expect { service_call }.to change { participant_profile.user.participant_identities.count }.by 1
    end

    it "creates an induction record for the new participant" do
      expect { service_call }.to change { induction_programme_2.induction_records.count }.by 1
    end

    context "record details" do
      let(:new_induction_record) { participant_profile.induction_records.latest }

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
      let(:new_induction_record) { participant_profile.current_induction_record }
      before do
        service.call(participant_profile:, induction_programme: induction_programme_2)
      end

      it "uses the existing participant identity" do
        expect(new_induction_record.preferred_identity).to eq participant_profile.participant_identity
      end

      it "sets the start date on the new induction as the current time" do
        expect(new_induction_record.start_date).to be_within(1.second).of Time.zone.now
      end

      it "sets the end date on the previous induction as the current time" do
        expect(original_induction.reload.end_date).to be_within(1.second).of Time.zone.now
      end
    end
  end
end
