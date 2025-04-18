# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolCohort, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:cohort) }
    it { is_expected.to belong_to(:school) }

    it { is_expected.to have_many(:current_induction_records).through(:induction_programmes) }
    it { is_expected.to have_many(:current_participant_profiles).through(:induction_programmes) }
    it { is_expected.to have_many(:transferring_in_induction_records).through(:induction_programmes) }
    it { is_expected.to have_many(:transferring_out_induction_records).through(:induction_programmes) }
  end

  describe "validation" do
    it "validates the uniqueness of school_id and cohort_id in combination" do
      school_cohort_1 = create(:school_cohort)
      school_cohort_2 = school_cohort_1.dup

      expect(school_cohort_2).to be_invalid
      expect(school_cohort_2.errors.messages[:school_id]).to include("The school is already linked to this cohort")
    end
  end

  it "updates the updated_at on participant profiles and users when meaningfully updated" do
    freeze_time
    school_cohort = create(:school_cohort)
    profile = create(:ect_participant_profile, school_cohort:, updated_at: 2.weeks.ago)
    user = profile.user
    user.update!(updated_at: 2.weeks.ago)

    school_cohort.update!(updated_at: Time.zone.now - 1.day)

    expect(user.reload.updated_at).to be_within(1.second).of Time.zone.now
    expect(profile.reload.updated_at).to be_within(1.second).of Time.zone.now
  end

  it "does not update the updated_at on participant profiles and users when not changed" do
    freeze_time
    school_cohort = create(:school_cohort)
    profile = create(:ect_participant_profile, school_cohort:, updated_at: 2.weeks.ago)
    user = profile.user
    user.update!(updated_at: 2.weeks.ago)

    school_cohort.save!

    expect(user.reload.updated_at).to be_within(1.second).of 2.weeks.ago
    expect(profile.reload.updated_at).to be_within(1.second).of 2.weeks.ago
  end

  it "updates analytics when any attributes changes" do
    school_cohort = create(:school_cohort, opt_out_of_updates: false)
    school_cohort.opt_out_of_updates = true
    expect {
      school_cohort.save!
    }.to have_enqueued_job(Analytics::UpsertECFSchoolCohortJob).with(
      school_cohort_id: school_cohort.id,
    )
  end

  it {
    is_expected.to define_enum_for(:induction_programme_choice).with_values(
      full_induction_programme: "full_induction_programme",
      core_induction_programme: "core_induction_programme",
      design_our_own: "design_our_own",
      school_funded_fip: "school_funded_fip",
      no_early_career_teachers: "no_early_career_teachers",
      not_yet_known: "not_yet_known",
    ).backed_by_column_of_type(:string)
  }

  describe ".for_year" do
    let(:school) { create(:school) }
    let(:cohort) { Cohort.find_by(start_year: 2020) || create(:cohort, start_year: 2020) }
    subject(:school_cohort) { create(:school_cohort, school:, cohort:) }

    before do
      school_cohort
    end

    it "returns the school cohort for the given year" do
      expect(school.school_cohorts.for_year(2020).first).to eq school_cohort
    end
  end

  describe ".dashboard_for_school" do
    let(:school) { create(:school) }
    let(:cohort_2020) { Cohort.find_by(start_year: 2020) || create(:cohort, start_year: 2020) }

    before do
      FactoryBot.rewind_sequences
      create_list(:school_cohort, 5, :consecutive_cohorts, school:)
      create(:school_cohort, cohort: cohort_2020, school:)
    end

    subject { SchoolCohort.dashboard_for_school(school:) }

    it "returns cohorts for the given school starting from 2021 ordered by the cohort's start year desc" do
      school_cohort_2021 = school.school_cohorts.for_year(2021).last
      school_cohort_2022 = school.school_cohorts.for_year(2022).last
      school_cohort_2023 = school.school_cohorts.for_year(2023).last
      school_cohort_2024 = school.school_cohorts.for_year(2024).last
      school_cohort_2025 = school.school_cohorts.for_year(2025).last

      expected_results = [school_cohort_2025, school_cohort_2024, school_cohort_2023, school_cohort_2022, school_cohort_2021]

      expect(subject).to eq expected_results
    end

    it "doesn't return the school cohorts for year 2020" do
      school_cohort_2020 = school.school_cohorts.for_year(2020).last

      expect(subject).not_to include school_cohort_2020
    end
  end

  describe "#lead_provider" do
    subject(:school_cohort) { create(:school_cohort) }

    context "when the school has chosen FIP for the cohort" do
      let(:lead_provider) { create(:lead_provider) }
      let(:delivery_partner) { create(:delivery_partner) }

      before do
        Partnership.create!(
          cohort: school_cohort.cohort,
          lead_provider:,
          school: school_cohort.school,
          delivery_partner:,
        )
      end

      it "returns the lead provider" do
        expect(school_cohort.lead_provider).to eq(lead_provider)
      end
    end

    context "when FIP is chosen and there are relationship partnerships" do
      let(:lead_provider) { create(:lead_provider, name: "Super Smashing Great Provider") }
      let(:delivery_partner) { create(:delivery_partner, name: "Wunderbar Partner") }

      before do
        Induction::CreateRelationship.call(school_cohort:,
                                           lead_provider:,
                                           delivery_partner:)
      end

      it "does not return the relationship provider" do
        expect(school_cohort.lead_provider).to be_nil
      end
    end

    context "when the school has chosen CIP for the cohort" do
      let(:cip) { create(:core_induction_programme) }

      before do
        school_cohort.update!(induction_programme_choice: "core_induction_programme",
                              core_induction_programme: cip)
      end

      it "returns nil" do
        expect(school_cohort.lead_provider).to be_nil
      end
    end
  end

  describe "#delivery_partner" do
    subject(:school_cohort) { create(:school_cohort) }

    context "when the school has chosen FIP for the cohort" do
      let(:lead_provider) { create(:lead_provider) }
      let(:delivery_partner) { create(:delivery_partner) }

      before do
        Partnership.create!(
          cohort: school_cohort.cohort,
          lead_provider:,
          school: school_cohort.school,
          delivery_partner:,
        )
      end

      it "returns the delivery partner" do
        expect(school_cohort.delivery_partner).to eq(delivery_partner)
      end
    end

    context "when FIP is chosen and there are relationship partnerships" do
      let(:lead_provider) { create(:lead_provider, name: "Super Smashing Great Provider") }
      let(:delivery_partner) { create(:delivery_partner, name: "Wunderbar Partner") }

      before do
        Induction::CreateRelationship.call(school_cohort:,
                                           lead_provider:,
                                           delivery_partner:)
      end

      it "does not return the relationship delivery partner" do
        expect(school_cohort.delivery_partner).to be_nil
      end
    end

    context "when the school has chosen CIP for the cohort" do
      let(:cip) { create(:core_induction_programme) }

      before do
        school_cohort.update!(induction_programme_choice: "core_induction_programme",
                              core_induction_programme: cip)
      end

      it "returns nil" do
        expect(school_cohort.delivery_partner).to be_nil
      end
    end
  end

  describe "#can_change_programme?" do
    %w[design_our_own no_early_career_teachers school_funded_fip].each do |programme|
      subject(:school_cohort) { create(:school_cohort, induction_programme_choice: programme) }

      it "returns true" do
        expect(school_cohort.can_change_programme?).to eq(true)
      end
    end
  end

  describe "#school_chose_diy?" do
    context "when school has chosen diy programme" do
      let(:school_cohort) { build(:school_cohort, induction_programme_choice: "design_our_own") }

      it "returns true" do
        expect(school_cohort.school_chose_diy?).to be true
      end
    end

    context "when school has not chosen diy programme" do
      let(:school_cohort) { build(:school_cohort, induction_programme_choice: "core_induction_programme") }

      it "returns false" do
        expect(school_cohort.school_chose_diy?).to be false
      end
    end
  end
end
