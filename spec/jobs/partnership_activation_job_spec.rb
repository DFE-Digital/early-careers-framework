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
    end

    it "updates the partnership and school cohort" do
      execute

      expect(partnership.reload.pending).to eql false
      expect(school_cohort.reload.induction_programme_choice).to eql "full_induction_programme"
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
