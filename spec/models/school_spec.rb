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
          postcode: "TEST2",
          school_status_code: 1,
          school_type_code: 1,
          administrative_district_code: "E123",
        )
      }.to change { School.count }.by(1)
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:partnerships) }
    it { is_expected.to have_many(:lead_providers).through(:partnerships) }
    it { is_expected.to have_many(:induction_coordinator_profiles_schools) }
    it { is_expected.to have_many(:induction_coordinator_profiles).through(:induction_coordinator_profiles_schools) }
    it { is_expected.to have_many(:induction_coordinators).through(:induction_coordinator_profiles).source(:user) }
    it { is_expected.to have_many(:early_career_teacher_profiles) }
    it { is_expected.to have_many(:early_career_teachers).through(:early_career_teacher_profiles) }
    it { is_expected.to have_many(:pupil_premiums) }
    it { is_expected.to have_many(:school_cohorts) }
    it { is_expected.to have_many(:nomination_emails) }
    it { is_expected.to have_many(:school_local_authorities) }
    it { is_expected.to have_many(:local_authorities).through(:school_local_authorities) }
    it { is_expected.to have_many(:school_local_authority_districts) }
    it { is_expected.to have_many(:local_authority_districts).through(:school_local_authority_districts) }
  end

  describe "eligibility" do
    let!(:open_school) { create(:school, school_status_code: 1) }
    let!(:closed_school) { create(:school, school_status_code: 2) }
    let!(:eligible_school_type) { create(:school, school_type_code: 1) }
    let!(:ineligible_school_type) { create(:school, school_type_code: 56) }
    let!(:english_school) { create(:school, administrative_district_code: "E123") }
    let!(:welsh_school) { create(:school, administrative_district_code: "W123", school_type_code: 30) }
    describe "#eligible?" do
      it "should be true for open schools" do
        expect(open_school.eligible?).to be true
      end

      it "should be false for closed schools" do
        expect(closed_school.eligible?).to be false
      end

      it "should be true for eligible establishment types" do
        expect(eligible_school_type.eligible?).to be true
      end

      it "should be false for ineligible establishment types" do
        expect(ineligible_school_type.eligible?).to be false
      end

      it "should be true for schools in England" do
        expect(english_school.eligible?).to be true
      end

      it "should be false for schools not in England" do
        expect(welsh_school.eligible?).to be false
      end
    end

    describe "scope eligible" do
      let(:eligible_school) { open_school }
      let(:ineligible_school) { closed_school }

      it "should only include eligible schools" do
        expect(School.eligible.all).to include(open_school, eligible_school_type, english_school)
        expect(School.eligible.all).not_to include(closed_school, ineligible_school_type, welsh_school)
      end
    end

    describe "#cip_only?" do
      it "should be false for fully eligible schools" do
        expect(open_school.cip_only?).to eql false
        expect(eligible_school_type.cip_only?).to eql false
        expect(english_school.cip_only?).to eql false
      end

      it "should be true for welsh schools" do
        expect(welsh_school.cip_only?).to eql true
      end

      it "should be false for closed welsh schools" do
        welsh_school.update!(school_status_code: 2)
        expect(welsh_school.cip_only?).to eql false
      end
    end

    describe "type codes" do
      it "should have no overlap between fully eligible and CIP only codes" do
        expect(School::CIP_ONLY_TYPE_CODES & School::ELIGIBLE_TYPE_CODES).to be_empty
      end
    end
  end

  describe "#not_registered?" do
    let(:school) { create(:school) }
    it "returns true if no one has registered the school" do
      expect(school.not_registered?).to be true
    end

    context "when school has an induction coordinator" do
      let(:user) { create(:user) }
      let!(:coordinator) { create(:induction_coordinator_profile, user: user, schools: [school]) }

      it "returns false" do
        expect(school.not_registered?).to be false
      end
    end
  end

  describe "#registered?" do
    let(:school) { create(:school) }
    it "returns false if there are no induction coordinators for the school" do
      expect(school.registered?).to be false
    end

    context "when school has an induction coordinator" do
      before do
        create(:user, :induction_coordinator, schools: [school])
      end

      it "returns true" do
        expect(school.registered?).to be true
      end
    end
  end

  describe "#full_address" do
    let(:address_line1) { Faker::Address.street_address }
    let(:address_line2) { Faker::Address.secondary_address }
    let(:address_line3) { Faker::Address.city }
    let(:postcode) { Faker::Address.postcode }

    it "returns every line of the address" do
      school = FactoryBot.create(
        :school,
        address_line1: address_line1,
        address_line2: address_line2,
        address_line3: address_line3,
        postcode: postcode,
      )

      expected_address = <<~ADDR
        #{address_line1}
        #{address_line2}
        #{address_line3}
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

  describe "School.search_by_name_or_urn_or_delivery_partner_for_year" do
    let(:cohort) { create(:cohort, start_year: Time.zone.now.year) }
    let(:lead_provider) { create(:lead_provider, cohorts: [cohort]) }
    let(:delivery_partner) { create(:delivery_partner, name: "Big Delivery Co.") }
    let!(:school_1) { create(:school, name: "foooschool", urn: "666666") }
    let!(:school_2) { create(:school, name: "barschool", urn: "99999") }

    before do
      create(:partnership, school: school_1, lead_provider: lead_provider, cohort: cohort)
      create(:partnership, school: school_2, lead_provider: lead_provider, delivery_partner: delivery_partner, cohort: cohort)
    end

    it "searches correctly by partial urn" do
      expect(School.search_by_name_or_urn_or_delivery_partner_for_year("foo", cohort.start_year)).to match_array [school_1]
    end

    it "searches correctly by partial name" do
      expect(School.search_by_name_or_urn_or_delivery_partner_for_year("999", cohort.start_year)).to match_array [school_2]
    end

    it "searches correctly by partial delivery partner name" do
      expect(School.search_by_name_or_urn_or_delivery_partner_for_year("del", cohort.start_year)).to match_array [school_2]
    end
  end

  describe "School.partnered_with_lead_provider" do
    let(:cohort) { create(:cohort, start_year: Time.zone.now.year) }
    let(:lead_provider) { create(:lead_provider, cohorts: [cohort]) }
    let(:schools) { create_list(:school, 2) }
    let(:not_this_cohort_school) { create(:school) }

    before do
      create(:lead_provider_profile, lead_provider: lead_provider)
      schools.each do |school|
        create(:partnership, school: school, lead_provider: lead_provider, cohort: cohort)
      end
      create(:partnership, school: not_this_cohort_school, lead_provider: lead_provider,
                           cohort: create(:cohort, start_year: Time.zone.now.year + 1))
    end

    it "returns schools partnered with the lead provider for the given cohort year" do
      expect(School.partnered_with_lead_provider(lead_provider.id, cohort.start_year)).to match_array schools
    end
  end

  describe "#contact_email" do
    let(:primary_contact_email) { Faker::Internet.email }
    let(:secondary_contact_email) { Faker::Internet.email }
    let(:school) { create(:school, primary_contact_email: primary_contact_email, secondary_contact_email: secondary_contact_email) }

    context "when no induction coordinator has been nominated" do
      it "returns the primary contact email" do
        expect(school.contact_email).to eql primary_contact_email
      end

      context "when there is no primary contact email" do
        let(:school) { create(:school, primary_contact_email: nil, secondary_contact_email: secondary_contact_email) }

        it "returns the secondary contact email" do
          expect(school.contact_email).to eql secondary_contact_email
        end
      end
    end

    context "when an induction coordinator has been nominated" do
      let!(:induction_coordinator) { create(:user, :induction_coordinator, schools: [school]) }

      it "returns the induction coordinator's email" do
        expect(school.contact_email).to eql induction_coordinator.email
      end
    end
  end

  describe "#delivery_partner_for" do
    let(:cohort_2020) { create(:cohort, start_year: 2020) }
    let(:cohort_2021) { create(:cohort, start_year: 2021) }
    let(:delivery_1) { create(:delivery_partner, name: "Ace Education") }
    let(:delivery_2) { create(:delivery_partner, name: "Super Learn") }
    let(:school) { create(:school) }

    before do
      create(:partnership, school: school, delivery_partner: delivery_1, cohort: cohort_2020)
      create(:partnership, school: school, delivery_partner: delivery_2, cohort: cohort_2021)
    end

    it "returns the delivery partner for the given cohort year" do
      expect(school.delivery_partner_for(2021)).to eq delivery_2
    end

    context "when there is no partner for the given cohort" do
      it "returns nil" do
        expect(school.delivery_partner_for(2022)).to be_nil
      end
    end
  end

  describe "#early_career_teacher_profiles_for" do
    let(:cohort_2020) { create(:cohort, start_year: 2020) }
    let(:cohort_2021) { create(:cohort, start_year: 2021) }
    let(:school) { create(:school) }
    let!(:teachers_2020) { create_list(:early_career_teacher_profile, 2, school: school, cohort: cohort_2020) }
    let!(:teachers_2021) { create_list(:early_career_teacher_profile, 3, school: school, cohort: cohort_2021) }

    it "returns the number of early career teachers for the given cohort year" do
      expect(school.early_career_teacher_profiles_for(2020)).to match_array teachers_2020
      expect(school.early_career_teacher_profiles_for(2021)).to match_array teachers_2021
    end

    context "when no early career teacher profiles are in the given cohort year" do
      it "returns and empty collection" do
        expect(school.early_career_teacher_profiles_for(2022)).to be_empty
      end
    end
  end

  describe "#characteristics_for" do
    context "when pupil premium uplift applies" do
      let(:school) { create(:school, :pupil_premium_uplift) }

      it "returns the correct characteristic for pupil premium" do
        expect(school.characteristics_for(2021)).to eq "Pupil premium above 40%"
      end
    end

    context "when sparsity uplift applies" do
      let(:school) { create(:school, :sparsity_uplift) }

      it "returns the correct characteristic" do
        expect(school.characteristics_for(2021)).to eq "Remote school"
      end
    end

    context "when pupil premium and sparcity uplifts apply" do
      let(:school) { create(:school, :pupil_premium_uplift, :sparsity_uplift) }

      it "returns the correct characteristics" do
        expect(school.characteristics_for(2021)).to eq "Pupil premium above 40% and Remote school"
      end
    end

    context "when neither pupil premium nor sparcity uplifts apply" do
      let(:school) { create(:school) }

      it "returns an empty string" do
        expect(school.characteristics_for(2021)).to be_blank
      end
    end
  end

  describe "#induction_tutor" do
    let(:school) { create(:school) }

    context "when an induction tutor exists" do
      let!(:tutor) { create(:induction_coordinator_profile, schools: [school]) }

      it "returns the first induction tutor" do
        expect(school.induction_tutor).to eq(tutor.user)
      end
    end

    context "when an induction tutor does not exist" do
      it "returns nil" do
        expect(school.induction_tutor).to be_nil
      end
    end
  end
end
