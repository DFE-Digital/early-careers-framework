# frozen_string_literal: true

require "rails_helper"

RSpec.describe School, type: :model do
  describe "School" do
    it "can be created" do
      expect {
        School.create(
          urn: "TEST_URN_2",
          name: "Test school two",
          address_line1: "Test address London",
          country: "England",
          postcode: "TEST2",
        )
      }.to change { School.count }.by(1)
    end
  end

  describe "associations" do
    it { is_expected.to have_one(:partnership) }
    it { is_expected.to have_one(:lead_provider).through(:partnership) }
    it { is_expected.to have_and_belong_to_many(:induction_coordinator_profiles) }
    it { is_expected.to have_many(:early_career_teacher_profiles) }
    it { is_expected.to have_many(:early_career_teachers).through(:early_career_teacher_profiles) }
    it { is_expected.to have_many(:pupil_premiums) }
    it { is_expected.to have_many(:school_local_authorities) }
    it { is_expected.to have_many(:local_authorities).through(:school_local_authorities) }
    it { is_expected.to have_many(:school_local_authority_districts) }
    it { is_expected.to have_many(:local_authority_districts).through(:school_local_authority_districts) }
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

    context "when school has an unconfirmed induction coordinator in the last 24 hours" do
      let(:user) { create(:user, confirmed_at: nil, confirmation_sent_at: 2.hours.ago) }
      let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }

      it "returns true" do
        expect(school.partially_registered?).to be true
      end
    end

    context "when unconfirmed induction coordinator was emailed more than 24 hours ago" do
      let(:user) { create(:user, confirmed_at: nil) }
      let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }

      before { user.update(confirmation_sent_at: 2.days.ago) }

      it "returns false" do
        expect(school.partially_registered?).to be false
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

  describe "#full_address" do
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

  describe "#pupil_premium_uplift?" do
    context "it has no pupil premium eligibility record" do
      let(:school) { create(:school) }
      it "returns false" do
        expect(school.pupil_premium_uplift?(2021)).to be false
      end
    end

    context "it has a pupil premium record with less than 40%" do
      let(:school) { create(:school, pupil_premiums: [build(:pupil_premium, :not_eligible)]) }

      it "returns false" do
        expect(school.pupil_premium_uplift?(2021)).to be false
      end
    end

    context "it has a pupil premium record with greater than 40%" do
      let(:school) { create(:school, :pupil_premium_uplift) }

      it "returns true" do
        expect(school.pupil_premium_uplift?(2021)).to be true
      end
    end
  end

  describe "#sparsity_uplift?" do
    context "it is part of a sparse district" do
      let(:school) { create(:school, :sparsity_uplift) }

      it "returns true" do
        expect(school.sparsity_uplift?).to be true
      end
    end

    context "it is part of a not sparse district" do
      let(:school) { create(:school) }

      it "returns false" do
        expect(school.sparsity_uplift?).to be false
      end
    end

    context "it is part of a previously sparse district" do
      let(:formerly_sparse_district) do
        build(:local_authority_district, district_sparsities: [build(:district_sparsity, start_year: 2020, end_year: 2021)])
      end
      let(:school) do
        create(:school, school_local_authority_districts: [
          build(:school_local_authority_district, local_authority_district: formerly_sparse_district),
        ])
      end

      it "returns false" do
        expect(school.sparsity_uplift?).to be false
      end

      it "returns true for the year the school was sparse" do
        expect(school.sparsity_uplift?(2020)).to be true
      end
    end
  end

  describe "scope :with_pupil_premium_uplift" do
    let!(:uplifted_school) { create(:school, :pupil_premium_uplift) }
    let!(:not_uplifted_school) { create(:school, pupil_premiums: [build(:pupil_premium, :not_eligible)]) }

    it "returns uplifted schools" do
      expect(School.with_pupil_premium_uplift(2021)).to include(uplifted_school)
      expect(School.with_pupil_premium_uplift(2021)).not_to include(not_uplifted_school)
    end
  end

  describe "scope :with_sparsity_uplift" do
    let!(:sparse_school) { create(:school, :sparsity_uplift) }
    let(:previously_sparse_district) do
      build(:local_authority_district, district_sparsities: [build(:district_sparsity, start_year: 2020, end_year: 2021)])
    end
    let!(:previously_sparse_school) do
      create(:school, school_local_authority_districts: [
        build(:school_local_authority_district, local_authority_district: previously_sparse_district),
      ])
    end
    let!(:not_sparse_school) { create(:school) }

    it "includes sparse schools" do
      expect(School.with_sparsity_uplift(2021)).to include(sparse_school)
    end

    it "does not include previously sparse schools" do
      expect(School.with_sparsity_uplift(2021)).not_to include(previously_sparse_school)
    end

    it "does not include not sparse schools" do
      expect(School.with_sparsity_uplift(2021)).not_to include(not_sparse_school)
    end

    it "includes previously sparse schools for the correct year" do
      expect(School.with_sparsity_uplift(2020)).to include(previously_sparse_school)
    end
  end

  describe "School.search_by_name_or_urn" do
    let!(:school_1) { create(:school, name: "foooschool", urn: "666666") }
    let!(:school_2) { create(:school, name: "barschool", urn: "99999") }

    it "searches correctly by partial urn" do
      expect(School.search_by_name_or_urn("foo").first).eql?(school_1)
    end

    it "searches correctly by partial name" do
      expect(School.search_by_name_or_urn("999").first).eql?(school_2)
    end
  end
end
