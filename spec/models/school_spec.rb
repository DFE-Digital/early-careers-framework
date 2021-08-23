# frozen_string_literal: true

require "rails_helper"

RSpec.describe School, type: :model do
  subject(:school) { create(:school) }
  let(:cohort) { create(:cohort) }
  let(:school_cohort) { create(:school_cohort, school: school, cohort: cohort) }

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
    it { is_expected.to have_many(:pupil_premiums) }
    it { is_expected.to have_many(:school_cohorts) }
    it { is_expected.to have_many(:nomination_emails) }
    it { is_expected.to have_many(:school_local_authorities) }
    it { is_expected.to have_many(:local_authorities).through(:school_local_authorities) }
    it { is_expected.to have_many(:school_local_authority_districts) }
    it { is_expected.to have_many(:local_authority_districts).through(:school_local_authority_districts) }
    it { is_expected.to have_many(:additional_school_emails) }
  end

  it "updates the updated_at on participant profiles and users" do
    freeze_time
    school_cohort = create(:school_cohort)
    profile = create(:participant_profile, :ect, school_cohort: school_cohort, updated_at: 2.weeks.ago)
    user = profile.user
    user.update!(updated_at: 2.weeks.ago)

    school_cohort.school.touch
    expect(user.reload.updated_at).to be_within(1.second).of Time.zone.now
    expect(profile.reload.updated_at).to be_within(1.second).of Time.zone.now
  end

  describe "eligibility" do
    let!(:open_school) { create(:school, school_status_code: 1) }
    let!(:closed_school) { create(:school, school_status_code: 2) }
    let!(:eligible_school_type) { create(:school, school_type_code: 1) }
    let!(:ineligible_school_type) { create(:school, school_type_code: 56) }
    let!(:english_school) { create(:school, administrative_district_code: "E123") }
    let!(:welsh_school) { create(:school, administrative_district_code: "W123", school_type_code: 30) }
    let!(:s41_school) { create(:school, section_41_approved: true, school_type_code: 30) }
    let!(:closed_s41_school) { create(:school, school_status_code: 2, section_41_approved: true) }
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

      it "should be true for open section 41 schools" do
        expect(s41_school.eligible?).to be true
      end

      it "should be false for closed section 41  schools" do
        expect(closed_s41_school.eligible?).to be false
      end
    end

    describe "scope eligible" do
      let(:eligible_school) { open_school }
      let(:ineligible_school) { closed_school }

      it "should only include eligible schools" do
        expect(School.eligible.all).to include(open_school, eligible_school_type, english_school, s41_school)
        expect(School.eligible.all).not_to include(closed_school, ineligible_school_type, welsh_school, closed_s41_school)
      end
    end

    describe "#cip_only?" do
      it "should be false for fully eligible schools" do
        expect(open_school.cip_only?).to eql false
        expect(eligible_school_type.cip_only?).to eql false
        expect(english_school.cip_only?).to eql false
        expect(s41_school.cip_only?).to eql false
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
    it "returns true if no one has registered the school" do
      expect(school.not_registered?).to be true
    end

    context "when school has an induction coordinator" do
      let!(:user) { create(:user, :induction_coordinator, school_ids: [school.id]) }

      it "returns false" do
        expect(school.not_registered?).to be false
      end
    end
  end

  describe "#registered?" do
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
    let!(:partnership_2020) { create(:partnership, school: school, delivery_partner: delivery_1, cohort: cohort_2020) }
    let!(:partnership_2021) { create(:partnership, school: school, delivery_partner: delivery_2, cohort: cohort_2021) }

    it "returns the delivery partner for the given cohort year" do
      expect(school.delivery_partner_for(2021)).to eq delivery_2
    end

    context "when there is no partner for the given cohort" do
      it "returns nil" do
        expect(school.delivery_partner_for(2022)).to be_nil
      end
    end

    context "when the partnership has been challenged" do
      let!(:partnership_2021) { create(:partnership, :challenged, school: school, cohort: cohort_2021) }

      it "returns nil" do
        expect(school.delivery_partner_for(2021)).to be_nil
      end

      it "returns the unchallenged delivery partner" do
        create(:partnership, school: school, cohort: cohort_2021, delivery_partner: delivery_1)
        expect(school.delivery_partner_for(2021)).to eql delivery_1
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
      it "returns an empty string" do
        expect(school.characteristics_for(2021)).to be_blank
      end
    end
  end

  describe "#induction_tutor" do
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

  describe "scope :without_induction_coordinator" do
    let!(:school_with_coordinator) { create(:user, :induction_coordinator).schools.first }
    let!(:school_without_coordinator) { create(:school) }

    it "returns only schools without induction coordinators" do
      expect(School.without_induction_coordinator).to include school_without_coordinator
      expect(School.without_induction_coordinator).not_to include school_with_coordinator
    end
  end

  describe "scope :not_opted_out" do
    let!(:cohort) { create(:cohort, :current) }
    let!(:opted_out_school) { create(:school_cohort, opt_out_of_updates: true, induction_programme_choice: "design_our_own", cohort: cohort).school }
    let!(:school_without_cohort) { create(:school) }
    let!(:cip_school) { create(:school_cohort, induction_programme_choice: "core_induction_programme", cohort: cohort).school }

    it "returns only schools who have not opted out" do
      expect(School.not_opted_out).to include(school_without_cohort, cip_school)
      expect(School.not_opted_out).not_to include opted_out_school
    end
  end

  describe "#partnered" do
    it "returns true when the school is in a partnership" do
      partnership = create(:partnership)
      expect(partnership.school.partnered?(partnership.cohort)).to be true
    end

    it "returns false when the school is not in a partnership" do
      expect(school.partnered?(create(:cohort))).to be false
    end

    it "returns false when the school is not in a partnership for the specified cohort" do
      partnership = create(:partnership)
      expect(partnership.school.partnered?(create(:cohort))).to be false
    end

    it "returns false when the partnership has been challenged" do
      partnership = create(:partnership, :challenged)
      expect(partnership.school.partnered?(partnership.cohort)).to be false
    end

    it "returns true when the school has a challenged and unchallenged partnership" do
      create(:partnership, school: school, cohort: cohort)
      create(:partnership, :challenged, school: school, cohort: cohort)

      expect(school.partnered?(cohort)).to be true
    end
  end

  describe "#participants_for" do
    it "includes active participants" do
      ect_profile = create(:participant_profile, :ect, school_cohort: school_cohort)
      mentor_profile = create(:participant_profile, :mentor, school_cohort: school_cohort)

      expect(school.participants_for(cohort)).to include(ect_profile.user, mentor_profile.user)
    end

    it "does not include participants with withdrawn records" do
      ect = create(:early_career_teacher_profile, :withdrawn_record, school_cohort: school_cohort).user
      mentor = create(:mentor_profile, :withdrawn_record, school_cohort: school_cohort).user

      expect(school.participants_for(cohort)).not_to include(ect, mentor)
    end

    it "does not include participants from other cohorts" do
      another_school_cohort = create(:school_cohort, cohort: create(:cohort), school: school)
      ect_profile = create(:participant_profile, :ect, school_cohort: another_school_cohort)
      mentor_profile = create(:participant_profile, :mentor, school_cohort: another_school_cohort)

      expect(school.participants_for(cohort)).not_to include(ect_profile.user, mentor_profile.user)
    end

    it "does not include participants from other schools" do
      another_school_cohort = create(:school_cohort, school: create(:school), cohort: cohort)
      ect_profile = create(:participant_profile, :ect, school_cohort: another_school_cohort)
      mentor_profile = create(:participant_profile, :mentor, school_cohort: another_school_cohort)

      expect(school.participants_for(cohort)).not_to include(ect_profile.user, mentor_profile.user)
    end
  end

  describe "#early_career_teacher_profiles_for" do
    it "includes active ECTs" do
      ect_profile = create(:early_career_teacher_profile, school_cohort: school_cohort)

      expect(school.early_career_teacher_profiles_for(cohort)).to include ect_profile
    end

    it "does not include ECTs with withdrawn records" do
      ect_profile = create(:early_career_teacher_profile, :withdrawn_record, school_cohort: school_cohort)

      expect(school.early_career_teacher_profiles_for(cohort)).not_to include ect_profile
    end

    it "does not include ECTs from other cohorts" do
      another_school_cohort = create(:school_cohort, cohort: create(:cohort), school: school)
      ect_profile = create(:early_career_teacher_profile, school_cohort: another_school_cohort)

      expect(school.early_career_teacher_profiles_for(cohort)).not_to include ect_profile
    end

    it "does not include ECTs from other schools" do
      another_school_cohort = create(:school_cohort, school: create(:school), cohort: cohort)
      ect_profile = create(:early_career_teacher_profile, school_cohort: another_school_cohort)

      expect(school.early_career_teacher_profiles_for(cohort)).not_to include ect_profile
    end

    it "does not include mentors" do
      mentor_profile = create(:mentor_profile, school_cohort: school_cohort)

      expect(school.early_career_teacher_profiles_for(cohort)).not_to include mentor_profile
    end
  end

  describe "#mentor_profiles_for" do
    it "includes active mentors" do
      mentor_profile = create(:mentor_profile, school_cohort: school_cohort)

      expect(school.mentor_profiles_for(cohort)).to include mentor_profile
    end

    it "does not include mentors with withdrawn records" do
      mentor_profile = create(:mentor_profile, :withdrawn_record, school_cohort: school_cohort)

      expect(school.mentor_profiles_for(cohort)).not_to include mentor_profile
    end

    it "does not include mentors from other cohorts" do
      another_school_cohort = create(:school_cohort, cohort: create(:cohort), school: school)
      mentor_profile = create(:mentor_profile, school_cohort: another_school_cohort)

      expect(school.mentor_profiles_for(cohort)).not_to include mentor_profile
    end

    it "does not include mentors from other schools" do
      another_school_cohort = create(:school_cohort, school: create(:school), cohort: cohort)
      mentor_profile = create(:mentor_profile, school_cohort: another_school_cohort)

      expect(school.mentor_profiles_for(cohort)).not_to include mentor_profile
    end

    it "does not include ECTs" do
      ect_profile = create(:early_career_teacher_profile, school_cohort: school_cohort)

      expect(school.mentor_profiles_for(cohort)).not_to include ect_profile
    end
  end
end
