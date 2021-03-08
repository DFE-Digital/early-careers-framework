# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_one(:admin_profile) }
    it { is_expected.to have_one(:induction_coordinator_profile) }
    it { is_expected.to have_one(:lead_provider_profile) }
    it { is_expected.to have_one(:lead_provider).through(:lead_provider_profile) }
    it { is_expected.to have_one(:early_career_teacher_profile) }
  end

  describe "validations" do
    subject { FactoryBot.create(:user) }
    it { is_expected.to validate_presence_of(:full_name).with_message("Enter a full name") }
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

  describe "#supplier_name" do
    it "returns the correct lead provider name" do
      user = create(:user, :lead_provider)

      expect(user.supplier_name).to eq user.lead_provider.name
    end

    it "returns nil when the user doesn't belong to a supplier" do
      user = create(:user)

      expect(user.supplier_name).to be_nil
    end
  end

  describe "#induction_coordinator?" do
    it "is expected to be true when the user has an induction coordinator profile" do
      user = create(:user, :induction_coordinator)

      expect(user.induction_coordinator?).to be true
    end

    it "is expected to be false when the user does not have an induction coordinator profile" do
      user = create(:user)

      expect(user.induction_coordinator?).to be false
    end
  end

  describe "#early_career_teacher?" do
    it "is expected to be true when the user has an early career teacher profile" do
      user = create(:user, :early_career_teacher)

      expect(user.early_career_teacher?).to be true
    end

    it "is expected to be false when the user does not have an early career teacher profile" do
      user = create(:user)

      expect(user.early_career_teacher?).to be false
    end
  end

  describe "#lead_provider?" do
    it "is expected to be true when the user has a lead provider profile" do
      user = create(:user, :lead_provider)

      expect(user.lead_provider?).to be true
    end

    it "is expected to be false when the user does not have a lead provider profile" do
      user = create(:user)

      expect(user.lead_provider?).to be false
    end
  end
end
