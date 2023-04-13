# frozen_string_literal: true

RSpec.describe Admin::Schools::Cohorts::OtherInfo, type: :component do
  let(:cohort) { instance_double Cohort, start_year: rand(2020..2030) }
  let(:school) { instance_double School, slug: "xyz" }
  let(:school_cohort) { FactoryBot.build(:seed_school_cohort) }

  before { render_inline(described_class.new(cohort:, school_cohort:, school:)) }

  it { is_expected.to have_link "Change", href: admin_school_change_programme_path(id: cohort.start_year, school_id: school.slug) }

  subject { rendered_content }

  context "without school cohort" do
    let(:school_cohort) { nil }

    it { is_expected.to have_content "No programme" }
  end

  context "with design your own school cohort" do
    let(:school_cohort) { build :school_cohort, induction_programme_choice: "design_our_own" }

    it { is_expected.to have_content "Not using service - designing own induction course" }
  end

  context "with school funded fip school cohort" do
    let(:school_cohort) { build :school_cohort, induction_programme_choice: "school_funded_fip" }

    it { is_expected.to have_content "Not using service - school funded full induction programme" }
  end

  context "with no_early_career_teachers school cohort" do
    let(:school_cohort) { build :school_cohort, induction_programme_choice: "no_early_career_teachers" }

    it { is_expected.to have_content "Not using service - no ECTs this year" }
  end

  context "with school cohort of unknown type" do
    let(:school_cohort) { instance_double SchoolCohort, induction_programme_choice: Faker::Lorem.words.join("_"), appropriate_body: FactoryBot.build(:seed_appropriate_body) }

    it { is_expected.to have_content "Not using service" }
  end
end
