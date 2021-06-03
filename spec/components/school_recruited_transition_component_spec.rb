# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolRecruitedTransitionComponent, type: :component do
  subject(:component) { described_class.new school_cohort: school_cohort }

  let(:school_cohort) { create :school_cohort, induction_programme_choice: induction_choice }
  let(:school) { school_cohort.school }
  let(:cohort) { school_cohort.cohort }

  context "when school did not choose cip" do
    let(:induction_choice) { SchoolCohort.induction_programme_choices.keys.without("core_induction_programme").sample }

    it { is_expected.not_to render }
  end

  context "when school has chosen core induction programme" do
    let(:induction_choice) { "core_induction_programme" }

    context "without fip partnership for given school" do
      it { is_expected.not_to render }
    end

    context "with fip partnership within challenge window" do
      let!(:partnership) { create :partnership, :in_challenge_window, school: school, cohort: cohort }

      it { is_expected.to render }

      context "and the partnership has been challenged" do
        let!(:partnership) { create :partnership, :challenged, school: school, cohort: cohort }

        it { is_expected.not_to render }
      end
    end
  end
end
