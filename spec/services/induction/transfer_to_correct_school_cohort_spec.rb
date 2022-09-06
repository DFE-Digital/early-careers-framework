# frozen_string_literal: true

RSpec.describe Induction::TransferToCorrectSchoolCohort do
  describe "#call" do
    let!(:current_cohort)        { create(:cohort, :current) }
    let(:next_cohort)            { create(:cohort, :next) }
    let(:school)                 { create(:school, name: "Test School") }
    let!(:current_school_cohort) { create(:school_cohort, :fip, :with_induction_programme, school:, cohort: current_cohort) }
    let(:next_school_cohort)     { create(:school_cohort, :fip, :with_induction_programme, school:, cohort: next_cohort) }
    let!(:current_schedule)      { create(:ecf_schedule, name: "2021 schedule", schedule_identifier: "ecf-standard-september", cohort: current_cohort) }
    let!(:next_schedule)         { create(:ecf_schedule, name: "2022 schedule", schedule_identifier: "ecf-standard-september", cohort: next_cohort) }
    let(:participant_profile)    { create(:ect, school_cohort: current_school_cohort) }
    let(:email)                  { participant_profile.user.email }

    let(:fake_logger) { double("logger", info: nil) }

    subject(:service) { described_class }

    let(:service_call) do
      service.call(email:,
                   cohort: next_cohort)
    end
    let!(:induction_record) { participant_profile.current_induction_record }
    before do
      # Induction::SetCohortInductionProgramme.call(school_cohort: current_school_cohort,
      #                                             programme_choice: current_school_cohort.induction_programme_choice)
      # @induction_record = Induction::Enrol.call(participant_profile:,
      #                                           induction_programme: current_school_cohort.default_induction_programme)
    end

    context "participant has active training status" do
      before do
        Induction::SetCohortInductionProgramme.call(school_cohort: next_school_cohort,
                                                    programme_choice: next_school_cohort.induction_programme_choice)
        service_call
        induction_record.reload
        participant_profile.reload
      end

      describe "induction record updates" do
        it "updates to the correct school cohort induction programme" do
          expect(induction_record.induction_programme).to eq(next_school_cohort.default_induction_programme)
        end

        it "updates to the correct schedule" do
          expect(induction_record.schedule).to eq(next_schedule)
          expect(induction_record.schedule.name).to eq("2022 schedule")
        end

        it "updates the start date" do
          expect(induction_record.start_date).to eq(next_cohort.academic_year_start_date)
        end
      end

      describe "participant profile updates" do
        it "updates the school cohort" do
          expect(participant_profile.school_cohort).to eq(next_school_cohort)
        end

        it "updates the schedule" do
          expect(participant_profile.schedule).to eq(next_schedule)
        end
      end
    end

    context "there is no active participant profile" do
      before do
        Induction::SetCohortInductionProgramme.call(school_cohort: next_school_cohort,
                                                    programme_choice: next_school_cohort.induction_programme_choice)
        allow(Rails).to receive(:logger).and_return(fake_logger)
        participant_profile.training_status_withdrawn!
        service_call
        induction_record.reload
        participant_profile.reload
      end

      it "returns early with an error" do
        expect(fake_logger).to have_received(:info).with("No participant profile with an active training status for #{email}")
      end

      it "does not update the induction record schedule" do
        expect(induction_record.schedule).to eq(current_schedule)
      end
    end

    context "there is no school cohort to transfer to" do
      before do
        allow(Rails).to receive(:logger).and_return(fake_logger)
        service_call
        induction_record.reload
        participant_profile.reload
      end

      it "returns early with an error" do
        expect(fake_logger).to have_received(:info).with("No school cohort to transfer to for #{email}")
      end

      it "does not update the induction record schedule" do
        expect(induction_record.schedule).to eq(current_schedule)
      end

      it "does not update the induction record start_date" do
        expect(induction_record.start_date).not_to eq(next_cohort.academic_year_start_date)
      end

      it "does not update the participant profile schedule" do
        expect(participant_profile.schedule).to eq(current_schedule)
      end
    end
  end
end
