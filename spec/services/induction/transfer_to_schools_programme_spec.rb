# frozen_string_literal: true

RSpec.describe Induction::TransferToSchoolsProgramme do
  describe "#call" do
    let(:school_1) { create(:school, name: "Transferring From School") }
    let(:school_2) { create(:school, name: "Transferring To School") }
    let(:school_cohort_1) { create(:school_cohort, :fip, school: school_1) }
    let(:school_cohort_2) { create(:school_cohort, :fip, school: school_2) }
    let(:partnership_1) { create(:partnership, cohort: school_cohort_1.cohort, school: school_1) }
    let(:partnership_2) { create(:partnership, cohort: school_cohort_2.cohort, school: school_2) }
    let!(:induction_programme_1) { create(:induction_programme, :fip, partnership: partnership_1, school_cohort: school_cohort_1) }
    let!(:induction_programme_2) { create(:induction_programme, :fip, partnership: partnership_2, school_cohort: school_cohort_2) }
    let(:teacher_profile) { create(:teacher_profile) }
    let(:participant_profile) { create(:ect_participant_profile, teacher_profile: teacher_profile, school_cohort: school_cohort_1) }
    let(:mentor_profile_1) { create(:mentor_participant_profile, school_cohort: school_cohort_1) }
    let(:mentor_profile_2) { create(:mentor_participant_profile, school_cohort: school_cohort_2) }
    let(:start_date) { 1.week.from_now }
    let(:end_date) { 1.week.ago }
    let(:new_email_address) { "peter.bonetti@new-school.example.com" }

    let(:new_induction_programme) { school_cohort_2.induction_programmes.order(:created_at).last }
    let(:new_partnership) { school_2.partnerships.order(:created_at).last }

    subject(:service) { described_class }

    let(:service_call) do
      service.call(participant_profile: participant_profile,
                   induction_programme: induction_programme_2,
                   email: new_email_address,
                   start_date: start_date,
                   end_date: end_date,
                   mentor_profile: mentor_profile_2)
    end

    before do
      @original_induction = Induction::Enrol.call(participant_profile: participant_profile,
                                                  induction_programme: induction_programme_1,
                                                  mentor_profile: mentor_profile_1)
    end

    it "creates a new identity with the given email" do
      expect { service_call }.to change { participant_profile.user.participant_identities.count }.by 1
    end

    it "creates an induction record for the new participant" do
      expect { service_call }.to change { induction_programme_2.induction_records.count }.by 1
    end

    context "record details" do
      before do
        service_call
        @new_induction_record = participant_profile.induction_records.latest
      end

      it "updates the previous induction record to leaving status" do
        expect(@original_induction.reload).to be_leaving_induction_status
        expect(@original_induction.end_date).to be_within(1.second).of end_date
      end

      it "enrols the participant in the new programme" do
        expect(@new_induction_record.induction_programme).to eq new_induction_programme
        expect(@new_induction_record).to be_active_induction_status
        expect(@new_induction_record.start_date).to be_within(1.second).of start_date
      end

      it "assigns the specified mentor to the induction" do
        expect(@new_induction_record.mentor_profile).to eq mentor_profile_2
      end

      it "assigns the preferred_identity to the induction" do
        expect(@new_induction_record.preferred_identity.email).to eq new_email_address
      end
    end

    context "without optional params" do
      before do
        service.call(participant_profile: participant_profile,
                     induction_programme: induction_programme_2)
        @new_induction_record = participant_profile.induction_records.latest
      end

      it "uses the existing participant identity" do
        expect(@new_induction_record.preferred_identity).to eq participant_profile.participant_identity
      end

      it "sets the start date on the new induction as the current time" do
        expect(@new_induction_record.start_date).to be_within(1.second).of Time.zone.now
      end

      it "sets the end date on the previous induction as the current time" do
        expect(@original_induction.reload.end_date).to be_within(1.second).of Time.zone.now
      end
    end
  end
end
