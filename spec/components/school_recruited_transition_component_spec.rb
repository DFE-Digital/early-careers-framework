# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "school has chosen a challengable programme" do |induction_choice|
  let(:school_cohort) { create :school_cohort, induction_programme_choice: induction_choice }
  let(:school) { school_cohort.school }
  let(:cohort) { school_cohort.cohort }

  context "without fip partnership for given school" do
    it { is_expected.not_to render }
  end

  context "with fip partnership within challenge window" do
    let!(:partnership) { create :partnership, :in_challenge_window, :pending, school: school, cohort: cohort }

    it { is_expected.to render }

    context "and the partnership has been challenged" do
      let!(:partnership) { create :partnership, :challenged, :pending, school: school, cohort: cohort }

      it { is_expected.not_to render }
    end
  end
end

RSpec.describe SchoolRecruitedTransitionComponent, type: :component do
  subject(:component) { described_class.new school_cohort: school_cohort }

  let(:school_cohort) { create :school_cohort, induction_programme_choice: induction_choice }

  context "when school did not choose CIP or an opt-out programme" do
    let(:induction_choice) { SchoolCohort.induction_programme_choices.keys.without("core_induction_programme", "design_our_own", "no_early_career_teachers").sample }

    it { is_expected.not_to render }
  end

  include_examples "school has chosen a challengable programme", "core_induction_programme"
  include_examples "school has chosen a challengable programme", "design_our_own"
  include_examples "school has chosen a challengable programme", "no_early_career_teachers"
end
