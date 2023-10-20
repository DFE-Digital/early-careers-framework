# frozen_string_literal: true

describe Finance::ECF::ContractVersion do
  let(:instance) { described_class.new(version_str) }

  context "when the version is not valid" do
    let(:version_str) { "ten" }

    it { expect { instance }.to raise_error(described_class::InvalidVersionError, "Version: ten") }
  end

  context "when the version is out of range" do
    let(:version_str) { "1.2345" }

    it { expect { instance }.to raise_error(described_class::VersionOutOfRangeError, "Version: 1.2345") }
  end

  describe "#increment!" do
    subject { instance.increment! }

    context "when the version format is '1.2.3'" do
      let(:version_str) { "1.2.3" }

      it { is_expected.to eq("1.2.4") }
    end

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

  describe "#numerical_value" do
    subject { instance.numerical_value }

    context "when the version format is '1.2.3'" do
      let(:version_str) { "1.2.3" }

      it { is_expected.to eq(1_002_003) }
    end

    context "when the version format is '1.2,3--4|55.'" do
      let(:version_str) { "1.2,3--4|55." }

      it { is_expected.to eq(1_002_003_004_055) }
    end

    context "when comparing version numbers" do
      it "gives the correct outcome" do
        v1 = described_class.new("12.3")
        v2 = described_class.new("1.234")

        expect(v1.numerical_value).to be > v2.numerical_value
      end
    end
  end

  describe "#to_s" do
    let(:version_str) { "1.2.3" }

    subject { instance.to_s }

    it { is_expected.to eq(version_str) }
  end
end
