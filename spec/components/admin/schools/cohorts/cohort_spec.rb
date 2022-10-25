# frozen_string_literal: true

RSpec.describe Admin::Schools::Cohorts::Cohort, type: :component do
  let(:cohort) { FactoryBot.build :cohort }
  let(:school_cohort) { FactoryBot.build(:school_cohort) }
  let(:school) { FactoryBot.build(:school, slug: "xyz") }

  let(:component) { described_class.new cohort:, school_cohort:, school: }
  subject { page }

  let(:cohort_content) { "#{cohort.display_name} cohort" }
  let(:fip_specific_content) { "Use an approved training provider" }
  let(:cip_specific_content) { "Use the DfE accredited materials" }
  let(:generic_content) { "Induction programme" }

  context "without school cohort" do
    let(:school_cohort) { nil }

    before { render_inline(component) }

    it { is_expected.to have_content(cohort_content) }
    it { is_expected.to have_content(generic_content) }
  end

  context "with CIP school cohort" do
    let(:school_cohort) { FactoryBot.build :school_cohort, :cip }

    before { render_inline(component) }

    it { is_expected.to have_content(cohort_content) }
    it { is_expected.to have_content(generic_content) }
    it { is_expected.to have_content(cip_specific_content) }
    it { is_expected.not_to have_content(fip_specific_content) }
  end

  context "with FIP school cohort" do
    let(:school_cohort) { FactoryBot.build :school_cohort, :fip }

    before { render_inline(component) }

    it { is_expected.to have_content(cohort_content) }
    it { is_expected.to have_content(generic_content) }
    it { is_expected.to have_content(fip_specific_content) }
    it { is_expected.not_to have_content(cip_specific_content) }
  end

  context "with school cohort that is neither CIP nor FIP" do
    let(:school_cohort) { instance_double(SchoolCohort, induction_programme_choice: Faker::Lorem.words.join("_")) }

    before { render_inline(component) }

    it { is_expected.to have_content(cohort_content) }
    it { is_expected.to have_content(generic_content) }
    it { is_expected.not_to have_content(fip_specific_content) }
    it { is_expected.not_to have_content(cip_specific_content) }
  end
end
