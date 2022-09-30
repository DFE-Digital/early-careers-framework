# frozen_string_literal: true

RSpec.describe Induction::AmendParticipantCohort do
  describe "#save" do
    let(:participant_profile) {}
    let(:source_cohort_start_year) { 2021 }
    let(:target_cohort_start_year) { 2022 }

    subject(:form) do
      described_class.new(participant_profile:, source_cohort_start_year:, target_cohort_start_year:)
    end

    context "when the source_cohort_start_year is not an integer" do
      let(:source_cohort_start_year) { "year" }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors.first.attribute).to eq(:source_cohort_start_year)
        expect(form.errors.first.message).to eq("Invalid value. Must be an integer between 2020 and #{Date.current.year}")
      end
    end

    context "when the source_cohort_start_year is older than 2020" do
      let(:source_cohort_start_year) { 2019 }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors.first.attribute).to eq(:source_cohort_start_year)
        expect(form.errors.first.message).to eq("Invalid value. Must be an integer between 2020 and #{Date.current.year}")
      end
    end

    context "when the source_cohort_start_year is more recent than the current year" do
      let(:source_cohort_start_year) { Date.current.year + 1 }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors.first.attribute).to eq(:source_cohort_start_year)
        expect(form.errors.first.message).to eq("Invalid value. Must be an integer between 2020 and #{Date.current.year}")
      end
    end

    context "when the target_cohort_start_year is not an integer" do
      let(:target_cohort_start_year) { "year" }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors.first.attribute).to eq(:target_cohort_start_year)
        expect(form.errors.first.message).to eq("Invalid value. Must be an integer between 2020 and #{Date.current.year}")
      end
    end

    context "when the target_cohort_start_year is older than 2020" do
      let(:target_cohort_start_year) { 2019 }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors.first.attribute).to eq(:target_cohort_start_year)
        expect(form.errors.first.message).to eq("Invalid value. Must be an integer between 2020 and #{Date.current.year}")
      end
    end

    context "when the target_cohort_start_year is more recent than the current year" do
      let(:target_cohort_start_year) { Date.current.year + 1 }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors.first.attribute).to eq(:target_cohort_start_year)
        expect(form.errors.first.message).to eq("Invalid value. Must be an integer between 2020 and #{Date.current.year}")
      end
    end

    context "when the target_cohort_start_year equals the source_cohort_start_year" do
      let(:target_cohort_start_year) { source_cohort_start_year }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors.first.attribute).to eq(:target_cohort_start_year)
        expect(form.errors.first.message).to eq("Invalid value. Must be different to #{source_cohort_start_year}")
      end
    end

    context "when the target cohort has not been setup in the service" do
      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors.first.attribute).to eq(:target_cohort)
        expect(form.errors.first.message)
          .to eq("Cohort starting on #{target_cohort_start_year} not setup on the service")
      end
    end

    context "enrolling participant" do
      let!(:source_cohort) { create(:cohort, start_year: source_cohort_start_year) }
      let!(:source_school_cohort) { create(:school_cohort, :fip, cohort: source_cohort) }
      let!(:school) { source_school_cohort.school }
      let!(:target_cohort) { create(:cohort, start_year: target_cohort_start_year) }
      let!(:target_cohort_schedule) { create(:ecf_schedule, cohort: target_cohort) }
      let!(:participant_profile) do
        create(:ect_participant_profile, training_status: :active, school_cohort: source_school_cohort)
      end

      before do
        Induction::SetCohortInductionProgramme.call(school_cohort: source_school_cohort,
                                                    programme_choice: source_school_cohort.induction_programme_choice)
      end

      context "when their is no participant" do
        let(:participant_profile) {}

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors.first.attribute).to eq(:participant_profile)
          expect(form.errors.first.message).to eq("Not registered")
        end
      end

      context "when the participant is not active" do
        before do
          participant_profile.withdrawn_record!
        end

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors.first.attribute).to eq(:participant_profile)
          expect(form.errors.first.message).to eq("Not active")
        end
      end

      context "when the participant has declarations" do
        before do
          allow_any_instance_of(described_class).to receive(:participant_declarations).and_return(true)
        end

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors.first.attribute).to eq(:participant_declarations)
          expect(form.errors.first.message).to eq("The participant must have no declarations")
        end
      end

      context "when the participant is not enrolled on the source school cohort" do
        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors.first.attribute).to eq(:induction_record)
          expect(form.errors.first.message)
            .to eq("The participant is not enrolled on the cohort starting on #{source_cohort_start_year}")
        end
      end

      context "when the school has not setup the target cohort" do
        before do
          Induction::Enrol.call(participant_profile:,
                                induction_programme: source_school_cohort.default_induction_programme)
        end

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors.first.attribute).to eq(:target_school_cohort)
          expect(form.errors.first.message)
            .to eq("Cohort starting on #{target_cohort_start_year} not setup on #{school.name}")
        end
      end

      context "when the school has setup the target cohort" do
        let!(:target_school_cohort) { create(:school_cohort, :fip, cohort: target_cohort, school:) }

        before do
          Induction::Enrol.call(participant_profile:,
                                induction_programme: source_school_cohort.default_induction_programme)
          Induction::SetCohortInductionProgramme.call(school_cohort: target_school_cohort,
                                                      programme_choice: target_school_cohort.induction_programme_choice)
        end

        context "when the transfer cannot be persisted" do
          before do
            allow(form).to receive(:start_date)
          end

          it "returns false and set errors" do
            expect(form.save).to be_falsey
            expect(form.errors.first.attribute).to eq(:induction_record)
            expect(form.errors.first.message).to eq("Start date can't be blank")
          end
        end

        it "returns true and set no errors" do
          expect(form.save).to be_truthy
          expect(form.errors).to be_empty
        end

        it "enrolls the participant in the target programme" do
          expect(form.save).to be_truthy

          induction_record = participant_profile.reload.induction_records.latest

          expect(induction_record.induction_programme).to eq(target_school_cohort.default_induction_programme)
          expect(induction_record.start_date).to eq(target_cohort.academic_year_start_date)
          expect(induction_record.schedule).to eq(Finance::Schedule::ECF.default_for(cohort: target_cohort))
          expect(participant_profile.school_cohort).to eq(target_school_cohort)
          expect(participant_profile.schedule).to eq(Finance::Schedule::ECF.default_for(cohort: target_cohort))
        end
      end
    end
  end
end
