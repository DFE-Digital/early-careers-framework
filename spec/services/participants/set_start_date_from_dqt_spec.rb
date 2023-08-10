# frozen_string_literal: true

RSpec.describe Participants::SetStartDateFromDQT do
  describe "#call" do
    let(:trn) { "1000864" }
    let(:teacher_profile) { create(:teacher_profile, trn:) }
    let(:participant_profile) { create(:ect_participant_profile, teacher_profile:) }
    let(:start_date) { 18.months.ago.to_date }
    let(:valid_record) do
      {
        "startDate" => start_date,
        "endDate" => nil,
        "status" => "InProgress",
        "periods"=>[{ "startDate" => start_date,
                      "endDate" => nil,
                      "terms" => nil,
                      "appropriateBody" => { "name" => "The Most Fantasic AB Ltd" } }],
      }
    end

    subject(:service) { described_class }

    it "sets the induction_start_date using the induction start date from DQT" do
      expect(DQT::GetInductionRecord).to receive(:call).with(trn:).once.and_return(valid_record)

      service.call(participant_profile:)

      expect(participant_profile.reload.induction_start_date).to eq start_date
    end

    context "when the DQT record is not found" do
      it "does not update the induction start date" do
        expect(DQT::GetInductionRecord).to receive(:call).with(trn:).once.and_return(nil)

        service.call(participant_profile:)

        expect(participant_profile.reload.induction_start_date).to be_nil
      end
    end

    context "when the participant is not an ECT" do
      let(:participant_profile) { create(:mentor_participant_profile, teacher_profile:) }

      it "does not look up the DQT record" do
        expect(DQT::GetInductionRecord).not_to receive(:call)
        service.call(participant_profile:)
      end

      it "does not update the induction start date" do
        service.call(participant_profile:)
        expect(participant_profile.reload.induction_start_date).to be_nil
      end
    end

    context "when there is no TRN on the teacher_profile" do
      let(:trn) { nil }

      it "does not look up the DQT record" do
        expect(DQT::GetInductionRecord).not_to receive(:call)
        service.call(participant_profile:)
      end

      it "does not update the induction start date" do
        service.call(participant_profile:)
        expect(participant_profile.reload.induction_start_date).to be_nil
      end
    end
  end
end
