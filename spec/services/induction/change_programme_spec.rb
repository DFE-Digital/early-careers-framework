# frozen_string_literal: true

RSpec.describe Induction::ChangeProgramme do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort) }
    let(:new_induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort) }
    let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort) }
    let!(:induction_record) { create(:induction_record, induction_programme: induction_programme, participant_profile: participant_profile, status: :active, start_date: 6.months.ago) }
    let(:action_date) { Time.zone.now }

    subject(:service) { described_class }

    it "adds a new induction record to the new programme for the participant" do
      expect {
        service.call(participant_profile: participant_profile,
                     end_date: action_date,
                     new_induction_programme: new_induction_programme,
                     start_date: action_date)
      }.to change { new_induction_programme.induction_records.count }.by 1
    end

    describe "induction records" do
      before do
        service.call(participant_profile: participant_profile, end_date: action_date, new_induction_programme: new_induction_programme, start_date: action_date)
      end

      it "updates the current induction record with status :changed" do
        expect(induction_record.reload).to be_changed_status
      end

      it "updates the current induction record with the end date" do
        expect(induction_record.reload.end_date).to be_within(1.second).of action_date
      end

      it "sets the new induction record data correctly" do
        expect(new_induction_programme.induction_records.first).to be_active_status
        expect(new_induction_programme.induction_records.first.start_date).to be_within(1.second).of action_date
        expect(new_induction_programme.induction_records.first.participant_profile).to eq participant_profile
      end
    end
  end
end
