# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_one(:admin_profile) }
    it { is_expected.to have_one(:induction_coordinator_profile) }
  end

  describe "validations" do
    subject { FactoryBot.create(:user) }
    it { is_expected.to validate_presence_of(:first_name).with_message("Enter a first name") }
    it { is_expected.to validate_presence_of(:last_name).with_message("Enter a last name") }
    it { is_expected.to validate_presence_of(:email).with_message("Enter an email") }
    it {
      is_expected.to validate_uniqueness_of(:email)
                       .case_insensitive
                       .with_message("This email address is already in use")
    }

    it "rejects an invalid email" do
      user = FactoryBot.build(:user, email: "invalid")

      expect(user.valid?).to be_falsey
      expect(user.errors.full_messages[0]).to include("Enter a valid email address")
    end
  end

  describe "associations" do
    it { is_expected.to have_one(:induction_coordinator_profile) }
    it { is_expected.to have_one(:lead_provider_profile) }
  end

  describe "#password_required?" do
    subject { build(:user) }
    it "is expected to be false" do
      expect(subject.password_required?).to be false
    end
  end

  describe "#admin?" do
    it "is expected to be true when the user has an admin profile" do
      user = create(:user, :admin)

      expect(user.admin?).to be true
    end

    it "is expected to be false when the user does not have an admin profile" do
      user = create(:user)

      expect(user.admin?).to be false
    end
  end
end
