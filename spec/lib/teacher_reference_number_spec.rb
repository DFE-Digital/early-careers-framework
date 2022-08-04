# frozen_string_literal: true

require "rails_helper"

RSpec.describe TeacherReferenceNumber do
  describe "valid?" do
    context "when the original value contains the correct number of digits" do
      it "returns true" do
        expect(described_class.new("RP99/12345")).to be_valid
        expect(described_class.new("12345")).to be_valid
        expect(described_class.new("1234567")).to be_valid
      end
    end

    context "when the original value is blank" do
      subject(:trn) { described_class.new("") }

      it "returns false" do
        expect(trn).not_to be_valid
      end

      it "sets the format_error to :blank" do
        trn.valid?
        expect(trn.format_error).to eq(:blank)
      end
    end

    context "when the original value contains fewer than 5 digits" do
      subject(:trn) { described_class.new("R12WWS/ 2") }

      it "returns false" do
        expect(trn).not_to be_valid
      end

      it "sets the format_error to :too_short" do
        trn.valid?
        expect(trn.format_error).to eq(:too_short)
      end
    end

    context "when the original value contains more than 7 digits" do
      subject(:trn) { described_class.new("RP11/12345678") }

      it "returns false" do
        expect(trn).not_to be_valid
      end

      it "sets the format_error to :too_long" do
        trn.valid?
        expect(trn.format_error).to eq(:too_long)
      end
    end
  end

  describe "#formatted_trn" do
    it "removes non-numeric characters" do
      expect(described_class.new("RP22/ 21 1 33").formatted_trn).to eq("2221133")
    end

    it "zero pads the value to 7-digits" do
      expect(described_class.new("RP99/123").formatted_trn).to eq("0099123")
    end

    context "when the original value is not valid" do
      it "returns nil" do
        expect(described_class.new("QWERTY123").formatted_trn).to be_nil
      end
    end
  end
end
