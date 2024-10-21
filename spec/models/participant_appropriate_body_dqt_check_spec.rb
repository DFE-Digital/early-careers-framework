# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantAppropriateBodyDQTCheck, type: :model do
  describe "#normalised_appropriate_body_name" do
    let(:record) { ParticipantAppropriateBodyDQTCheck.new(appropriate_body_name:) }

    context "when appropriate_body_name contains a leading school name in parentheses" do
      let(:appropriate_body_name) { "Some AB (Leading School Name)" }

      it "returns the leading school name" do
        expect(record.normalised_appropriate_body_name).to eq("Leading School Name")
      end
    end

    context "when appropriate_body_name does not contain parentheses" do
      let(:appropriate_body_name) { "Some AB" }

      it "returns the full appropriate_body_name" do
        expect(record.normalised_appropriate_body_name).to eq("Some AB")
      end
    end

    context "when appropriate_body_name is nil" do
      let(:appropriate_body_name) { nil }

      it "returns nil" do
        expect(record.normalised_appropriate_body_name).to be_nil
      end
    end

    context "when appropriate_body_name has parentheses with extra characters" do
      let(:appropriate_body_name) { "Some AB (Leading School - Extra Info)" }

      it "returns what is inside the parentheses" do
        expect(record.normalised_appropriate_body_name).to eq("Leading School - Extra Info")
      end
    end
  end
end
