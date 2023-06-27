# frozen_string_literal: true

require "rails_helper"

RSpec.describe EnrolSchoolCohortsJob do
  describe "#perform" do
    let(:school_cohort) { create(:school_cohort, :fip) }
    let!(:ect) { create(:ect, school_cohort:) }
    let(:job_run) { described_class.new.perform }

    context "when there is no induction programme" do
      it "should add an induction programme" do
        expect { job_run }.to change { school_cohort.induction_programmes.count }.by 1
      end

      it "should set the default induction programme" do
        job_run
        expect(school_cohort.reload.default_induction_programme).to be_present
        expect(school_cohort.default_induction_programme).to eq school_cohort.induction_programmes.first
      end

      it "should enrol participants into the induction programme" do
        job_run
        ect.reload
        school_cohort.reload
        expect(ect.current_induction_programme).to eq school_cohort.default_induction_programme
      end

      context "when programme is a FIP" do
        let!(:partnership) { create(:partnership, school: school_cohort.school, cohort: school_cohort.cohort) }
        it "adds the partnership to the programme" do
          job_run
          school_cohort.reload
          expect(school_cohort.default_induction_programme.partnership).to eq partnership
        end
      end

      context "when programme is a CIP" do
        let(:school_cohort) { create(:school_cohort, :cip) }

        it "adds the cip materials provider to the programme" do
          job_run
          school_cohort.reload
          expect(school_cohort.default_induction_programme.core_induction_programme).to eq school_cohort.core_induction_programme
        end
      end
    end

    context "when there is an existing induction programme" do
      before do
        Induction::SetCohortInductionProgramme.call(school_cohort:,
                                                    programme_choice: "full_induction_programme")
      end

      it "does not add an induction programme" do
        expect { job_run }.not_to change { school_cohort.induction_programmes.count }
      end
    end
  end
end
