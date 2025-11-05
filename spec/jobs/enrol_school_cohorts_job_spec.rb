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

    describe "BUG: Multiple open InductionRecords" do
      it "creates multiple open IRs when EnrolSchoolCohortsJob runs for participants with existing IRs" do
        # ❌ BUG: This test proves that when EnrolSchoolCohortsJob runs for a school cohort
        # where participants already have open InductionRecords, it creates multiple open IRs

        # Setup: School cohort with programme choice but NO programmes (makes it eligible for the job)
        cohort = create(:cohort, :current)
        school = create(:school, name: "Test School")

        # Create partnership FIRST (required for FIP programme creation at line 15 of the job)
        create(:partnership, school:, cohort:)

        test_school_cohort = create(:school_cohort,
                                    school:,
                                    cohort:,
                                    induction_programme_choice: "full_induction_programme")

        ect_profile = create(:ect_participant_profile, school_cohort: test_school_cohort)

        # Create a second school cohort with a programme for the existing IR
        # (Simulating a participant who was previously enrolled elsewhere)
        other_school = create(:school, name: "Other School")
        other_school_cohort = create(:school_cohort, school: other_school, cohort:)
        existing_programme = create(:induction_programme, :fip, school_cohort: other_school_cohort)

        Induction::Enrol.call(
          participant_profile: ect_profile,
          induction_programme: existing_programme,
          start_date: 1.year.ago,
        )

        # Verify participant has 1 open IR and test_school_cohort has no programmes (eligible for job)
        expect(ect_profile.induction_records.where(end_date: nil).count).to eq(1)
        expect(test_school_cohort.reload.induction_programmes.count).to eq(0)

        # Run the actual job (this is what runs at 3am daily via cron)
        EnrolSchoolCohortsJob.new.perform

        # ❌ BUG: Now we have 2 open IRs at DIFFERENT schools
        ect_profile.reload
        open_records = ect_profile.induction_records.where(end_date: nil)
        expect(open_records.count).to eq(2)

        # At different schools with different programmes
        schools = open_records.map(&:school)
        expect(schools).to contain_exactly(school, other_school)
        programmes = open_records.map(&:induction_programme)
        expect(programmes.count).to eq(2)
        expect(programmes).to all(be_a(InductionProgramme))
      end
    end
  end
end
