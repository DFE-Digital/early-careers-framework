# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PartnershipFinalisationJob" do
  describe "#perform" do
    let(:pending_partnership) { create(:partnership, :pending) }
    let!(:school_cohort) do
      SchoolCohort.create!(
        school: pending_partnership.school,
        cohort: pending_partnership.cohort,
        induction_programme_choice: "core_induction_programme",
      )
    end

    it "updates the partnership and school cohort" do
      PartnershipActivationJob.new.perform(pending_partnership)

      expect(pending_partnership.reload.pending).to eql false
      expect(school_cohort.reload.induction_programme_choice).to eql "full_induction_programme"
    end

    it "does nothing when the partnership request has been challenged" do
      challenged_partnership = create(:partnership, :pending, :challenged)
      school_cohort = SchoolCohort.create!(
        school: challenged_partnership.school,
        cohort: challenged_partnership.cohort,
        induction_programme_choice: "core_induction_programme",
      )

      PartnershipActivationJob.new.perform(pending_partnership)

      expect(challenged_partnership.reload.pending).to eql true
      expect(school_cohort.reload.induction_programme_choice).to eql "core_induction_programme"
    end
  end
end
