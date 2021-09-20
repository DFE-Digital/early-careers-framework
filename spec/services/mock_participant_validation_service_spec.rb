# frozen_string_literal: true

require "rails_helper"

RSpec.describe MockParticipantValidationService do
  let(:trn) { "1234567" }
  let(:nino) { "QQ123456A" }
  let(:full_name) { "John Smith" }
  let(:dob) { Date.new(1970, 1, 2) }

  describe "::validate" do
    it "return hash" do
      result = described_class.validate(
        trn: "2222222",
        full_name: full_name,
        date_of_birth: dob,
        nino: nino,
      )

      expect(result).to be_a(Hash)
    end
  end

  describe "#validate" do
    subject do
      described_class.new(
        trn: trn,
        full_name: full_name,
        date_of_birth: dob,
        nino: nino,
      )
    end

    context "when trn is an odd number" do
      it "returns nil" do
        expect(subject.validate).to be_nil
      end
    end

    context "when trn is an even number" do
      let(:trn) { "2468024" }

      it "returns a hash with data" do
        expect(subject.validate).to be_a(Hash)
      end
    end
  end
end
