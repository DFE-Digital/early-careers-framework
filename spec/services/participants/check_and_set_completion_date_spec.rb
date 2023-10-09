# frozen_string_literal: true

require "rails_helper"

RSpec.describe Participants::CheckAndSetCompletionDate do
  let(:participant_profile) { create(:seed_ect_participant_profile, :valid) }
  let!(:induction_record) { create(:seed_induction_record, :with_induction_programme, :with_schedule, participant_profile:) }
  let(:trn) { participant_profile.teacher_profile.trn }
  let(:completion_date) { 1.month.ago.to_date }
  let(:dqt_induction_record) { { "endDate" => completion_date } }

  subject(:service_call) { described_class.call(participant_profile:) }

  describe "#call" do
    before do
      allow(DQT::GetInductionRecord).to receive(:call).with(trn:).and_return(dqt_induction_record)
      service_call
    end

    it "sets the induction completion date" do
      expect(participant_profile.induction_completion_date).to eq completion_date
    end

    context "when the participant does not have a completion date" do
      let(:dqt_induction_record) { nil }

      it "does not set a completion date" do
        expect(participant_profile.induction_completion_date).to be_nil
      end
    end

    context "when the participant is not an ECT" do
      let(:participant_profile) { create(:seed_mentor_participant_profile, :valid) }

      it "does not set a completion date" do
        expect(participant_profile.induction_completion_date).to be_nil
      end
    end
  end
end
