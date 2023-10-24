# frozen_string_literal: true

class TestRecordableInformation
  include HasRecordableInformation
end

describe HasRecordableInformation do
  before { allow(Rails.logger).to receive(:info) }

  let(:instance) { TestRecordableInformation.new }

  describe "#record_info" do
    subject { instance.recorded_info }

    it { is_expected.to be_empty }

    context "when information has been recorded" do
      before { instance.record_info("info") }

      it { expect(instance).to have_recorded_info("info") }
    end
  end

  describe "#reset_recorded_info" do
    before do
      instance.record_info("info")
      instance.reset_recorded_info
    end

    it { expect(instance.recorded_info).to be_empty }
  end
end
