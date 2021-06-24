# frozen_string_literal: true

require "rails_helper"

RSpec.describe PartnershipActivationJob do
  describe "#perform" do
    let(:partnership) { create(:partnership, :pending) }
    let(:report_id) { partnership.report_id }

    let!(:school_cohort) do
      SchoolCohort.create!(
        school: partnership.school,
        cohort: partnership.cohort,
        induction_programme_choice: "core_induction_programme",
      )
    end

    def execute
      subject.perform(partnership: partnership, report_id: report_id)
      partnership.reload
      school_cohort.reload
    end

    it "updates the partnership and school cohort" do
      execute

      expect(partnership).not_to be_pending
      expect(school_cohort).to be_full_induction_programme
    end

    context "when school had chosen to opt-out" do
      before do
        school_cohort.update!(induction_programme_choice: "no_early_career_teachers",
                              opt_out_of_updates: true)
      end

      it "opts the school back in" do
        execute

        expect(school_cohort).not_to be_opt_out_of_updates
      end
    end

    context "when partnership has been challenged" do
      let(:partnership) { create(:partnership, :pending, :challenged) }

      it "does nothing" do
        expect { execute }.not_to change { partnership.reload.attributes }
      end
    end

    context "when given report_id does not match the report_id on the partnership" do
      let(:report_id) { Random.uuid }

      it "does nothing" do
        expect { execute }.not_to change { partnership.reload.attributes }
      end
    end
  end
end
