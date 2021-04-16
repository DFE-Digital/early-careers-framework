# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolCohortPolicy, type: :policy do
  subject { described_class.new(user, school_cohort) }

  let(:user) { create(:user) }
  let(:school_cohort) { create :school_cohort }

  it { is_expected.not_to permit_actions([:info, :show, :edit, :update, :success]) }

  context "being an admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_actions([:info, :show, :edit, :update, :success]) }
  end

  context "being induction coordinator" do
    let(:user) { create(:user, :induction_coordinator) }

    context "but not coordinating given school" do
      it { is_expected.not_to permit_actions([:info, :show, :edit, :update, :success]) }
    end

    context "coordinating induction for given school" do
      let(:user) { create(:user, :induction_coordinator, schools: [school_cohort.school]) }

      it { is_expected.to permit_actions([:info, :show, :edit, :update, :success]) }
    end
  end

  describe described_class::Scope do
    subject(:scope) { described_class.new(user, SchoolCohort.all) }

    context "for induction_coordinator" do
      let(:user) { create :user, :induction_coordinator, schools: coordinating_schools }
      let(:coordinating_schools) { create_list :school, 2 }
      let(:other_schools) { create_list :school, 2 }
      let(:coordinating_cohorts) { Array.new(rand 3..5) { create :school_cohort, school: coordinating_schools.sample }}
      let(:other_cohorts) { Array.new(rand 3..5) { create :school_cohort, school: other_schools.sample }}

      it "only returns cohorts for which user is nominated as a induction coordinator" do
        expect(scope.resolve).to match_array coordinating_cohorts
      end
    end

    context "for an admin" do
      let(:user) { create :user, :admin }
      let(:cohorts) { Array.new(rand 3..5) { create :school_cohort }}

      it "all the school cohorts" do
        expect(scope.resolve).to match_array cohorts
      end
    end
  end
end
