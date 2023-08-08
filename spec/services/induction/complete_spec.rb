# frozen_string_literal: true

RSpec.describe Induction::Complete do
  describe "#call" do
    let(:school_cohort) { create :school_cohort }
    let(:induction_programme) { create(:induction_programme, :fip, school_cohort:) }
    let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
    let(:mentor_profile) { create(:mentor_participant_profile, school_cohort:) }
    let!(:induction_record) { Induction::Enrol.call(induction_programme:, participant_profile:, start_date: 6.months.ago, mentor_profile:) }
    let(:completion_date) { 2.weeks.ago.to_date }

    subject(:service) { described_class }

    it "sets the completion date on the profile" do
      service.call(participant_profile:, completion_date:)

      expect(participant_profile.induction_completion_date).to eq completion_date
    end

    it "sets the induction induction_status to completed on the latest induction record" do
      service.call(participant_profile:, completion_date:)

      expect(participant_profile.latest_induction_record).to be_completed_induction_status
    end

    it "sets the induction record end_date on the previous induction record" do
      service.call(participant_profile:, completion_date:)

      expect(induction_record.reload.end_date).to be_within(2.seconds).of Time.zone.now
    end

    it "removes the mentor_profile from the induction record" do
      service.call(participant_profile:, completion_date:)

      expect(induction_record.reload.mentor_profile).to eq mentor_profile
      expect(participant_profile.latest_induction_record.mentor_profile).to be_nil
    end

    context "when the latest induction record already has an end date" do
      before do
        induction_record.leaving!(1.week.ago)
      end

      it "does not update the end_date" do
        expect {
          service.call(participant_profile:, completion_date:)
        }.not_to change { induction_record.end_date }
      end
    end

    context "when the latest induction record has a future start date" do
      before do
        induction_record.update!(start_date: 1.week.from_now)
      end

      it "updates the induction status" do
        service.call(participant_profile:, completion_date:)
        expect(induction_record.reload).to be_completed_induction_status
      end
    end
  end
end
