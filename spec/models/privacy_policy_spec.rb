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
end
