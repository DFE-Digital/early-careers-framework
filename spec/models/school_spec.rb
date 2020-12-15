# frozen_string_literal: true

require "rails_helper"

RSpec.describe School, type: :model do
  describe "School" do
    it "can be created" do
      expect {
        School.create(urn: "TEST_URN_2", name: "Test school two", address_line1: "Test address London", country: "England", postcode: "TEST2")
      }.to change { School.count }.by(1)
    end

    it { is_expected.to have_one(:partnership) }
    it { is_expected.to have_one(:lead_provider).through(:partnership) }
    it { is_expected.to have_and_belong_to_many(:induction_coordinator_profiles) }
    it { is_expected.to have_and_belong_to_many(:school_domains) }
  end
end
