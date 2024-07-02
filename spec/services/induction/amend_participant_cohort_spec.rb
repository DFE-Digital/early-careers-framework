# frozen_string_literal: true

RSpec.describe Induction::AmendParticipantCohort do
  describe "#save" do
    let(:participant_profile) {}
    let(:source_cohort_start_year) { Cohort.previous.start_year }
    let(:target_cohort_start_year) { Cohort.current.start_year }

    subject(:form) do
      described_class.new(participant_profile:,
                          source_cohort_start_year:,
                          target_cohort_start_year:)
    end

    context "when the source_cohort_start_year is not an integer" do
      let(:source_cohort_start_year) { "year" }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors[:source_cohort_start_year]).to include("Invalid value. Must be an integer between 2020 and #{Date.current.year}")
      end
    end

    context "when the source_cohort_start_year is older than 2020" do
      let(:source_cohort_start_year) { 2019 }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors[:source_cohort_start_year]).to include("Invalid value. Must be an integer between 2020 and #{Date.current.year}")
      end
    end

    context "when the source_cohort_start_year is more recent than the current year" do
      let(:source_cohort_start_year) { Date.current.year + 1 }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors[:source_cohort_start_year]).to include("Invalid value. Must be an integer between 2020 and #{Date.current.year}")
      end
    end

    context "when the target_cohort_start_year is not an integer" do
      let(:target_cohort_start_year) { "year" }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors[:target_cohort_start_year]).to include("Invalid value. Must be an integer between 2020 and #{Date.current.year}")
      end
    end

    context "when the target_cohort_start_year is older than 2020" do
      let(:target_cohort_start_year) { "2019" }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors[:target_cohort_start_year]).to include("Invalid value. Must be an integer between 2020 and #{Date.current.year}")
      end
    end

    context "when the target_cohort_start_year is more recent than the current year" do
      let(:target_cohort_start_year) { Date.current.year + 1 }

      it "returns false and set errors" do
        expect(form.save).to be_falsey
        expect(form.errors[:target_cohort_start_year]).to include("Invalid value. Must be an integer between 2020 and #{Date.current.year}")
      end
    end

    context "enrolling participant" do
      let(:lead_provider) { nil }
      let!(:source_cohort) { create(:cohort, start_year: source_cohort_start_year) }
      let!(:source_school_cohort) { create(:school_cohort, :fip, cohort: source_cohort, lead_provider:) }
      let!(:school) { source_school_cohort.school }
      let!(:target_cohort) { Cohort.find_by_start_year(target_cohort_start_year) }
      let!(:target_cohort_schedule) { create(:ecf_schedule, cohort: target_cohort) }
      let!(:participant_profile) do
        create(:ect_participant_profile, school_cohort: source_school_cohort)
      end

      before do
        Induction::SetCohortInductionProgramme.call(school_cohort: source_school_cohort,
                                                    programme_choice: source_school_cohort.induction_programme_choice)
      end

      context "when the participant has induction completion date" do
        before do
          participant_profile.update!(induction_completion_date: Date.current)
        end

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors[:participant_profile]).to include("The participant has completion date")
        end
      end

      context "when the participant has mentor completion date" do
        before do
          participant_profile.update!(mentor_completion_date: Date.current)
        end

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors[:participant_profile]).to include("The participant has completion date")
        end
      end

      context "when the target_cohort_start_year is not matching that of the schedule" do
        let(:schedule) { Finance::Schedule::ECF.default_for(cohort: Cohort.previous) }

        subject(:form) do
          described_class.new(participant_profile:, source_cohort_start_year:, target_cohort_start_year:, schedule:)
        end

        before do
          Induction::Enrol.call(participant_profile:,
                                induction_programme: source_school_cohort.default_induction_programme)
        end

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors[:target_cohort_start_year]).to include("The target year must match that of the schedule")
        end
      end

      context "when there is no participant" do
        let(:participant_profile) {}

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors[:participant_profile]).to include("Not a participant profile record")
        end
      end

      context "when the participant is not active" do
        before do
          participant_profile.withdrawn_record!
        end

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors[:participant_profile]).to include("The participant is not active")
        end
      end

      context "when the participant has notes" do
        before do
          participant_profile.notes = "Some note"
        end

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors[:participant_profile]).to include("The participants has notes that block a cohort change")
        end
      end

      context "when they are transferring back to their original cohort" do
        before do
          target_cohort.update!(payments_frozen_at: 1.month.ago)
          participant_profile.update!(cohort_changed_after_payments_frozen: true)
        end

        it "do not set errors" do
          expect(form.save).to be_falsey
          expect(form.errors[:target_cohort_start_year]).to be_blank
        end
      end

      context "when the participant is transferred from their their payments-frozen cohort to the currently one open for registration" do
        let(:target_cohort_start_year) { Cohort.active_registration_cohort.start_year }

        before do
          source_cohort.update!(payments_frozen_at: Time.current)
        end

        context "when the participant is eligible to be transferred" do
          before do
            allow(participant_profile).to receive(:eligible_to_change_cohort_and_continue_training?).and_return(true)
          end

          it "do not set errors" do
            expect(form.save).to be_falsey
            expect(form.errors[:participant_profile]).to be_blank
          end
        end

        context "when the participant is not eligible to be transferred" do
          before do
            allow(participant_profile).to receive(:eligible_to_change_cohort_and_continue_training?).and_return(false)
          end

          it "set errors on participant profile" do
            expect(form.save).to be_falsey
            expect(form.errors[:participant_profile]).to include("Participant not eligible to be transferred from their current cohort")
          end
        end
      end

      context "when the participant is transferred back to their original payments-frozen cohort" do
        before do
          target_cohort.update!(payments_frozen_at: 1.month.ago)
          participant_profile.update!(cohort_changed_after_payments_frozen: true)
        end

        context "when the participant has billable declarations in current cohort" do
          before do
            participant_profile.participant_declarations.create!(declaration_date: Date.new(source_cohort_start_year, 10, 10),
                                                                 declaration_type: :started,
                                                                 state: :eligible,
                                                                 course_identifier: "ecf-induction",
                                                                 cpd_lead_provider: create(:cpd_lead_provider),
                                                                 user: participant_profile.user,
                                                                 cohort: source_cohort)
          end

          it "set errors" do
            expect(form.save).to be_falsey
            expect(form.errors[:participant_profile]).to include("Participant not eligible to be transferred back to their original cohort")
            expect(form.errors[:participant_profile]).to include("The participant has billable declarations in their current cohort")
          end
        end

        context "when the participant has no billable declarations in destination cohort" do
          it "set errors" do
            expect(form.save).to be_falsey
            expect(form.errors[:participant_profile]).to include("Participant not eligible to be transferred back to their original cohort")
            expect(form.errors[:participant_profile]).to include("The participant has no billable declarations in destination cohort")
          end
        end

        context "when the participant is eligible to be transferred" do
          before do
            participant_profile.participant_declarations.create!(declaration_date: Date.new(target_cohort_start_year, 10, 10),
                                                                 declaration_type: :started,
                                                                 state: :eligible,
                                                                 course_identifier: "ecf-induction",
                                                                 cpd_lead_provider: create(:cpd_lead_provider),
                                                                 user: participant_profile.user,
                                                                 cohort: target_cohort)
          end

          it "set no errors" do
            expect(form.save).to be_falsey
            expect(form.errors[:participant_profile]).to be_blank
          end
        end
      end

      %i[submitted eligible payable paid].each do |declaration_state|
        context "when the participant has #{declaration_state} declarations" do
          before do
            participant_profile.participant_declarations.create!(declaration_date: Date.new(2020, 10, 10),
                                                                 declaration_type: :started,
                                                                 state: declaration_state,
                                                                 course_identifier: "ecf-induction",
                                                                 cpd_lead_provider: create(:cpd_lead_provider),
                                                                 user: participant_profile.user,
                                                                 cohort: participant_profile.schedule.cohort)
          end

          it "returns false and set errors on declarations" do
            expect(form.save).to be_falsey
            expect(form.errors[:participant_declarations]).to include("The participant has billable or submitted declarations")
          end
        end
      end

      %i[voided ineligible awaiting_clawback clawed_back].each do |declaration_state|
        context "when the participant has #{declaration_state} declarations" do
          before do
            participant_profile.participant_declarations.create!(declaration_date: Date.new(2020, 10, 10),
                                                                 declaration_type: :started,
                                                                 state: declaration_state,
                                                                 course_identifier: "ecf-induction",
                                                                 cpd_lead_provider: create(:cpd_lead_provider),
                                                                 user: participant_profile.user,
                                                                 cohort: participant_profile.schedule.cohort)
          end

          it "do not set errors on declarations" do
            expect(form.save).to be_falsey
            expect(form.errors[:participant_declarations]).to be_blank
          end
        end
      end

      context "when the participant has no declarations" do
        it "do not set errors on declarations" do
          expect(form.save).to be_falsey
          expect(form.errors[:participant_declarations]).to be_blank
        end
      end

      context "when the participant is not enrolled on the source school cohort" do
        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors[:induction_record]).to include("No induction record for the participant on the cohort starting on #{source_cohort_start_year}")
        end
      end

      context "when a NIoT-associated participant is to be moved to a cohort earlier than 2023" do
        let(:lead_provider) { LeadProvider.find_or_create_by!(name: "National Institute of Teaching") }
        let(:source_cohort_start_year) { 2023 }
        let(:target_cohort_start_year) { 2022 }
        let(:cohort_2023) { Cohort.find_by(start_year: 2023) || create(:cohort, start_year: 2023) }

        before do
          Induction::Enrol.call(participant_profile:,
                                induction_programme: source_school_cohort.default_induction_programme)
          lead_provider.provider_relationships.create!(delivery_partner: DeliveryPartner.first, cohort: cohort_2023)
        end

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors[:induction_record]).to include("A NIoT-associated participant can't be moved to a cohort earlier than 2023")
        end
      end

      context "when the school has not setup the target cohort" do
        before do
          Induction::Enrol.call(participant_profile:,
                                induction_programme: source_school_cohort.default_induction_programme)
        end

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors[:target_school_cohort]).to include("Cohort starting on #{target_cohort_start_year} not setup on #{school.name}")
        end
      end

      context "when the participant is in the target cohort but not in the target schedule" do
        let(:target_cohort_start_year) { source_cohort_start_year }
        let(:schedule) { create(:ecf_extended_schedule, cohort: target_cohort) }

        subject(:form) do
          described_class.new(participant_profile:, source_cohort_start_year:, schedule:)
        end

        before do
          Induction::Enrol.call(participant_profile:,
                                induction_programme: source_school_cohort.default_induction_programme)
        end

        it "moves the current induction record and participant profile to the target schedule" do
          expect(form.save).to be_truthy
          expect(form.errors).to be_empty
          expect(participant_profile.schedule).to eq(schedule)
          expect(participant_profile.latest_induction_record.schedule).to eq(schedule)
        end
      end

      context "when the school has not setup a default induction programme for the target cohort" do
        let!(:target_school_cohort) { create(:school_cohort, :fip, cohort: target_cohort, school:) }

        before do
          Induction::Enrol.call(participant_profile:,
                                induction_programme: source_school_cohort.default_induction_programme)
        end

        it "returns false and set errors" do
          expect(form.save).to be_falsey
          expect(form.errors[:induction_programme]).to include("Default induction programme for #{target_cohort_start_year} not setup on #{school.name}")
        end
      end

      context "when the school has setup the target cohort with default induction programme" do
        let!(:target_school_cohort) { create(:school_cohort, :fip, cohort: target_cohort, school:) }

        before do
          Induction::Enrol.call(participant_profile:,
                                induction_programme: source_school_cohort.default_induction_programme)
          Induction::SetCohortInductionProgramme.call(school_cohort: target_school_cohort,
                                                      programme_choice: target_school_cohort.induction_programme_choice)
        end

        context "when the cohort change cannot be persisted" do
          before do
            allow(form).to receive(:schedule)
          end

          it "returns false and set errors" do
            expect(form.save).to be_falsey
            expect(form.errors[:induction_record]).to include("Validation failed: Schedule must exist")
          end
        end

        context "when the participant has no declarations" do
          it "returns true and set no errors" do
            expect(form.save).to be_truthy
            expect(form.errors).to be_empty
          end

          it "enrolls the participant in the target programme" do
            expect(form.save).to be_truthy

            induction_record = participant_profile.reload.induction_records.latest

            expect(induction_record.induction_programme).to eq(target_school_cohort.default_induction_programme)
            expect(induction_record.schedule).to eq(Finance::Schedule::ECF.default_for(cohort: target_cohort))
            expect(participant_profile.school_cohort).to eq(target_school_cohort)
            expect(participant_profile.schedule).to eq(Finance::Schedule::ECF.default_for(cohort: target_cohort))
          end
        end

        describe "declaration states", mid_cohort: true do
          %i[voided ineligible awaiting_clawback clawed_back].each do |declaration_state|
            context "when the participant has #{declaration_state} declarations and no billable or changeable declarations" do
              before do
                participant_profile.participant_declarations.create!(declaration_date: Date.new(Cohort.previous.start_year, 10, 10),
                                                                     declaration_type: :started,
                                                                     state: declaration_state,
                                                                     course_identifier: "ecf-induction",
                                                                     cpd_lead_provider: create(:cpd_lead_provider),
                                                                     user: participant_profile.user,
                                                                     cohort: participant_profile.schedule.cohort)
              end

              it "executes the transfer" do
                expect(form.save).to be_truthy
                expect(participant_profile.reload.latest_induction_record.cohort_start_year).to eq(target_cohort_start_year)
              end

              it "returns true and set no errors" do
                expect(form.save).to be_truthy
                expect(form.errors).to be_empty
              end

              context "when the transfer is due to payments frozen in the cohort of the participant" do
                before do
                  source_cohort.update!(payments_frozen_at: Time.current)
                  allow(participant_profile).to receive(:eligible_to_change_cohort_and_continue_training?).and_return(true)
                  create(:ecf_extended_schedule, cohort: target_cohort)
                end

                it "mark the participant as transferred for that reason" do
                  expect(form.save).to be_truthy
                  expect(participant_profile).to be_cohort_changed_after_payments_frozen
                end

                it "sets the schedule to ecf-extended-september" do
                  expect(form.save).to be_truthy
                  expect(participant_profile.reload.schedule.schedule_identifier).to eq("ecf-extended-september")
                  expect(participant_profile.schedule.cohort).to eq(target_cohort)
                  expect(participant_profile.latest_induction_record.schedule).to eq(participant_profile.schedule)
                end

                it "mark the participant as transferred from the original cohort" do
                  expect(form.save).to be_truthy
                end
              end
            end
          end
        end

        context "when source_cohort_start_year matches target_cohort_start_year" do
          let(:current_induction_record) { participant_profile.induction_records.latest }

          subject(:form) do
            described_class.new(participant_profile:,
                                source_cohort_start_year: target_cohort_start_year,
                                target_cohort_start_year:)
          end

          before do
            participant_profile.update!(schedule: create(:ecf_extended_schedule, cohort: target_cohort))
            Induction::ChangeProgramme.call(participant_profile:,
                                            end_date: Date.current,
                                            new_induction_programme: target_school_cohort.default_induction_programme,
                                            start_date: Date.current)
          end

          it "returns true and set no errors" do
            expect(form.save).to be_truthy
            expect(form.errors).to be_empty
          end

          it "keeps the current induction record in the same schedule and cohort" do
            expect { form.save }.to not_change { current_induction_record.reload.schedule }
                                      .and not_change { current_induction_record.reload.cohort_start_year }
                                             .and not_change { current_induction_record.reload.induction_programme }
          end

          it "keeps the participant profile in the same schedule and cohort" do
            expect { form.save }.to not_change { participant_profile.schedule }
                                      .and not_change { participant_profile.school_cohort }
          end
        end
      end
    end
  end
end
