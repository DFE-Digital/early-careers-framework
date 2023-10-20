# frozen_string_literal: true

describe Finance::ECF::ContractVersion do
  let(:version_str) { "1.2.3" }

  let(:instance) { described_class.new(version_str) }

  context "when the version is not valid" do
    let(:version_str) { "ten" }

    it { expect { instance }.to raise_error(described_class::InvalidVersionError, "Version: ten") }
  end

  describe "#increment!" do
    subject { instance.increment! }

    it { is_expected.to eq("1.2.4") }

    context "when the version format is '1'" do
      let(:version_str) { "1" }

      it { is_expected.to eq("2") }
    end

    context "when the version format is '1.2'" do
      let(:version_str) { "1.2" }

      it { is_expected.to eq("1.3") }
    end

    context "when the version format is '1-2-3'" do
      let(:version_str) { "1-2-3" }

      it { is_expected.to eq("1-2-4") }
    end

    context "when the version format is '1.2,3--4|55.'" do
      let(:version_str) { "1.2,3--4|55." }

      it { is_expected.to eq("1.2,3--4|56.") }
    end
  end

  describe "#to_s" do
    subject { instance.to_s }

    it { is_expected.to eq(version_str) }
  end
end
