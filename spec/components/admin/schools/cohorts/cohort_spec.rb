# frozen_string_literal: true

RSpec.describe Admin::Schools::Cohorts::Cohort, type: :view_component do
  let(:cohort) { FactoryBot.build :cohort }
  let(:school_cohort) { FactoryBot.build(:school_cohort) if rand < 0.5 }

  component { described_class.new cohort:, school_cohort: }

  stub_component Admin::Schools::Cohorts::OtherInfo
  stub_component Admin::Schools::Cohorts::CipInfo
  stub_component Admin::Schools::Cohorts::FipInfo

  it { is_expected.to have_content "#{cohort.display_name} cohort" }

  context "without school cohort" do
    let(:school_cohort) { nil }

    it { is_expected.to have_rendered_component(Admin::Schools::Cohorts::OtherInfo).with(cohort:, school_cohort: nil) }
  end

  context "with CIP school cohort" do
    let(:school_cohort) { FactoryBot.build :school_cohort, :cip }

    it { is_expected.to have_rendered_component(Admin::Schools::Cohorts::CipInfo).with(school_cohort:) }
  end

  context "with FIP school cohort" do
    let(:school_cohort) { FactoryBot.build :school_cohort, :fip }

    it { is_expected.to have_rendered_component(Admin::Schools::Cohorts::FipInfo).with(school_cohort:) }
  end

  context "with school cohort that is neither CIP nor FIP" do
    let(:school_cohort) { instance_double(SchoolCohort, induction_programme_choice: Faker::Lorem.words.join("_")) }

    it { is_expected.to have_rendered_component(Admin::Schools::Cohorts::OtherInfo).with(cohort:, school_cohort:) }
  end
end
