# frozen_string_literal: true

require "rails_helper"

RSpec.describe Partnership, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:lead_provider) }
    it { is_expected.to belong_to(:cohort) }
  end

  describe "validations" do
    subject { FactoryBot.build(:partnership, status: status) }

    context "when status is accepted" do
      let(:status) { "accepted" }

      it "is valid without a reason for rejection" do
        expect(subject.valid?).to be_truthy
      end
    end

    context "when status is rejected" do
      let(:status) { "rejected" }

      it "is invalid without a reason for rejection" do
        expect(subject.valid?).to be_falsey
        expect(subject.errors.full_messages[0]).to include("Select a reason")
      end
    end
  end
end
