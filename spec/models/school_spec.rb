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
  end

  describe "#not_registered?" do
    let(:school) { create(:school) }
    it "returns true if no one has registered the school" do
      expect(school.not_registered?).to be true
    end

    context "when school has an induction coordinator" do
      let(:user) { create(:user, confirmed_at: 1.day.ago) }
      let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }

      it "returns false" do
        expect(school.not_registered?).to be false
      end
    end
  end

  describe "#fully_registered?" do
    let(:school) { create(:school) }
    it "returns false if no one has registered the school" do
      expect(school.fully_registered?).to be false
    end

    context "when school has an unconfirmed induction coordinator" do
      let(:user) { create(:user, confirmed_at: nil) }
      let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }

      it "returns false" do
        expect(school.fully_registered?).to be false
      end
    end

    context "when school has a confirmed induction coordinator" do
      let(:user) { create(:user, confirmed_at: 1.day.ago) }
      let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }

      it "returns true" do
        expect(school.fully_registered?).to be true
      end
    end
  end

  describe "#partially_registered?" do
    let(:school) { create(:school) }
    it "returns false if no one has registered the school" do
      expect(school.partially_registered?).to be false
    end

    context "when school has an unconfirmed induction coordinator" do
      let(:user) { create(:user, confirmed_at: nil) }
      let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }

      it "returns false if no one has registered a school" do
        expect(school.partially_registered?).to be true
      end
    end

    context "when school has a confirmed induction coordinator" do
      let(:user) { create(:user, confirmed_at: 1.day.ago) }
      let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }

      it "returns false if no one has registered a school" do
        expect(school.partially_registered?).to be false
      end
    end
  end

  describe "School#full_address" do
    let(:address_line1) { Faker::Address.street_address }
    let(:address_line2) { Faker::Address.secondary_address }
    let(:address_line3) { Faker::Address.city }
    let(:address_line4) { Faker::Address.state }
    let(:postcode) { Faker::Address.postcode }

    it "returns every line of the address" do
      school = FactoryBot.create(
        :school,
        address_line1: address_line1,
        address_line2: address_line2,
        address_line3: address_line3,
        address_line4: address_line4,
        postcode: postcode,
      )

      expected_address = <<~ADDR
        #{address_line1}
        #{address_line2}
        #{address_line3}
        #{address_line4}
        #{postcode}
      ADDR
      expect(school.full_address).to eq(expected_address)
    end

    it "skips blank lines of the address" do
      school = FactoryBot.create(
        :school,
        address_line1: address_line1,
        postcode: postcode,
      )

      expected_address = <<~ADDR
        #{address_line1}
        #{postcode}
      ADDR
      expect(school.full_address).to eq(expected_address)
    end
  end
end
