# frozen_string_literal: true

require "rails_helper"

RSpec.describe PrivacyPolicy, type: :model do
  describe ".current" do
    before do
      %w[9.12 10.1 10.11].each do |version|
        major, minor = version.split(".")
        FactoryBot.create :privacy_policy, major_version: major, minor_version: minor
      end
    end

    it "returns the version of privacy policy with higher semantic version" do
      expect(described_class.current.version).to eq "10.11"
    end
  end

  describe "#acceptance_required?" do
    let(:user) { create :user, :induction_coordinator }
    subject(:policy) { create :privacy_policy, major_version: 3, minor_version: 5 }
    subject(:result) { policy.acceptance_required?(user) }

    context "as an induction coordinator" do
      context "when user has accepted previous major version of policy" do
        before do
          create(:privacy_policy, major_version: 2, minor_version: rand(0..10)).accept!(user)
        end

        it { is_expected.to be true }
      end

      context "when user has accepted any previous minor version within the same current version" do
        before do
          create(:privacy_policy, major_version: 3, minor_version: rand(0..4)).accept!(user)
        end

        it { is_expected.to be false }
      end

      context "when user has accepted any next minor version within the same current version" do
        before do
          create(:privacy_policy, major_version: 3, minor_version: rand(6..10)).accept!(user)
        end

        it { is_expected.to be false }
      end

      context "when user has already accepted higher major version" do
        before do
          create(:privacy_policy, major_version: 4, minor_version: rand(0..10)).accept!(user)
        end

        it { is_expected.to be false }
      end

      context "when user has not accepted any policy version yet" do
        it { is_expected.to be true }
      end
    end

    context "as a user not being an induction coordinator" do
      let(:user) { create :user }

      it { is_expected.to be false }
    end
  end
end
