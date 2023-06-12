# frozen_string_literal: true

RSpec.describe Induction::ChangeProgramme do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
    let(:new_induction_programme) { create(:induction_programme, :fip, school_cohort:) }
    let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
    let!(:induction_record) { Induction::Enrol.call(induction_programme:, participant_profile:, start_date: 6.months.ago) }
    let(:action_date) { Time.zone.now }
    let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }

    subject(:service) { described_class }

    it "adds a new induction record to the new programme for the participant" do
      expect {
        service.call(participant_profile:,
                     end_date: action_date,
                     new_induction_programme:,
                     start_date: action_date)
      }.to change { new_induction_programme.induction_records.count }.by 1
    end

    describe "induction records" do
      before do
        service.call(participant_profile:, end_date: action_date, new_induction_programme:, start_date: action_date, mentor_profile:)
      end

      it "updates the current induction record with status :changed" do
        expect(induction_record.reload).to be_changed_induction_status
      end

      it "updates the current induction record with the end date" do
        expect(induction_record.reload.end_date).to be_within(1.second).of action_date
      end

      it "sets the new induction record data correctly" do
        induction_record = new_induction_programme.induction_records.first
        expect(induction_record).to be_active_induction_status
        expect(induction_record.start_date).to be_within(1.second).of action_date
        expect(induction_record.participant_profile).to eq participant_profile
        expect(induction_record.mentor_profile).to eq mentor_profile
      end
    end

    context "when the participant is a Mentor" do
      let(:participant_profile) { create(:mentor_participant_profile, school_cohort:) }

      context "when the mentor is not moving to another school" do
        it "doesn't remove the mentor from the shcool mentor pool" do
          expect(Mentors::ChangeSchool).not_to receive(:call)

          service.call(participant_profile:, end_date: action_date, new_induction_programme:, start_date: action_date)
        end
      end

      context "when then mentor is moving to another school" do
        let(:school_cohort_of_a_another_school) { create :school_cohort }
        let(:new_induction_programme) { create(:induction_programme, :fip, school_cohort: school_cohort_of_a_another_school) }

        it "removes the mentor from the shcool mentor pool" do
          expect(Mentors::ChangeSchool).to receive(:call)

          service.call(participant_profile:, end_date: action_date, new_induction_programme:, start_date: action_date)
        end
      end
    end
  end
end
