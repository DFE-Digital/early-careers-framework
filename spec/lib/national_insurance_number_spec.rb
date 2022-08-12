# frozen_string_literal: true

require "rails_helper"

RSpec.describe NationalInsuranceNumber do
  describe "#valid?" do
    context "when the original value with spaces removed sticks to the official NINO format definition" do
      it "returns true" do
        expect(described_class.new("AB   12 34 56 A")).to be_valid
        expect(described_class.new("Ab123456A")).to be_valid
        expect(described_class.new("ab 12   3456  a")).to be_valid
      end
    end

    context "when the original value is blank" do
      subject(:nino) { described_class.new("") }

      it "returns false" do
        expect(nino).not_to be_valid
      end

      it "sets the error to :blank" do
        nino.valid?
        expect(nino.error).to eq(:blank)
      end
    end

    context "when the original value do not stick to the official NINO format definition" do
      subject(:nino) { described_class.new("QQ 12 34 45 A") }

      it "returns false" do
        expect(nino).not_to be_valid
      end

      it "sets the error to :invalid" do
        nino.valid?
        expect(nino.error).to eq(:invalid)
      end
    end
  end

  describe "#formatted_nino" do
    it "upcase and removes space characters" do
      expect(described_class.new("ab 12 34 56 A").formatted_nino).to eq("AB123456A")
    end

    context "when the original value is not valid" do
      it "returns nil" do
        expect(described_class.new("QQ123456A").formatted_nino).to be_nil
      end
    end
  end
end
