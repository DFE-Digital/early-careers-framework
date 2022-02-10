# frozen_string_literal: true

RSpec.describe Induction::Transfer do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort) }
    let(:new_induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort) }
    let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
    let!(:induction_record) { create(:induction_record, induction_programme: induction_programme, participant_profile: participant_profile, status: :active) }
    let(:start_date) { 5.days.from_now }
    let(:end_date) { Time.zone.now }

    subject(:service) { described_class }

    it "updates the current induction record with status :transferred" do
      service.call(participant_profiles: participant_profile, end_date: end_date, new_induction_programme: new_induction_programme, start_date: start_date)

      expect(induction_record.reload).to be_transferred
    end

    it "updates the current induction record with the end date" do
      service.call(participant_profiles: participant_profile, end_date: end_date, new_induction_programme: new_induction_programme, start_date: start_date)

      expect(induction_record.reload.end_date).to eq end_date
    end

    it "adds a new induction record to the new programme for the participant" do
      expect {
        service.call(participant_profiles: participant_profile, end_date: end_date, new_induction_programme: new_induction_programme, start_date: start_date)
      }.to change { new_induction_programme.induction_records.count }.by 1
    end

    it "sets the new induction record data correctly" do
      service.call(participant_profiles: participant_profile, end_date: end_date, new_induction_programme: new_induction_programme, start_date: start_date)

      expect(new_induction_programme.induction_records.first).to be_active
      expect(new_induction_programme.induction_records.first.start_date).to eq start_date
      expect(new_induction_programme.induction_records.first.participant_profile).to eq participant_profile
    end
  end
end
