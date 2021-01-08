# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_one(:admin_profile) }
    it { is_expected.to have_one(:induction_coordinator_profile) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe "#password_required?" do
    subject { build(:user) }
    it "is expected to be false" do
      expect(subject.password_required?).to be false
    end
  end
end
