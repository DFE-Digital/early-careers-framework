# frozen_string_literal: true

RSpec.describe Induction::AmendParticipantCohort do
  describe "#save" do
    let(:participant_profile) {}
    let(:source_cohort_start_year) { Cohort.previous.start_year }
    let(:target_cohort_start_year) { Cohort.current.start_year }

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
      let(:target_cohort_start_year) { "2019" }

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

    context "when the target cohort has not been setup in the service" do
      let!(:source_cohort_start_year) { Cohort.next.start_year }
      let!(:target_cohort_start_year) { Cohort.next.start_year + 1 }

      it "returns false and set errors" do
        travel_to Date.new(Cohort.ordered_by_start_year.last.start_year + 2, 9, 1)

        expect(form.save).to be_falsey
        expect(form.errors[:target_cohort]).to_not be_nil
        expect(form.errors.messages[:target_cohort].first)
          .to eq("starting on #{target_cohort_start_year} not setup on the service")
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
          expect(form.errors.first.attribute).to eq(:target_cohort_start_year)
          expect(form.errors.first.message).to eq("Invalid value. Must match that of the schedule")
        end
      end

      context "when there is no participant" do
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

      %i[submitted eligible payable paid].each do |declaration_state|
        context "when the participant has #{declaration_state} declarations" do
          before do
            participant_profile.participant_declarations.create!(declaration_date: Date.new(2020, 10, 10),
                                                                 declaration_type: :started,
                                                                 state: declaration_state,
                                                                 course_identifier: "ecf-induction",
                                                                 cpd_lead_provider: create(:cpd_lead_provider),
                                                                 user: participant_profile.user)
          end

          it "returns false and set errors" do
            expect(form.save).to be_falsey
            expect(form.errors.first.attribute).to eq(:participant_declarations)
            expect(form.errors.first.message).to eq("The participant has billable or submitted declarations")
          end
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
            .to eq("starting on #{target_cohort_start_year} not setup on #{school.name}")
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
          expect(form.errors.first.attribute).to eq(:induction_programme)
          expect(form.errors.first.message)
            .to eq("default for #{target_cohort_start_year} not setup on #{school.name}")
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
            expect(form.errors.first.attribute).to eq(:induction_record)
            expect(form.errors.first.message).to eq("Schedule must exist")
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

        %i[voided ineligible awaiting_clawback clawed_back].each do |declaration_state|
          context "when the participant has #{declaration_state} declarations and no billable or changeable declarations" do
            before do
              participant_profile.participant_declarations.create!(declaration_date: Date.new(Cohort.previous.start_year, 10, 10),
                                                                   declaration_type: :started,
                                                                   state: declaration_state,
                                                                   course_identifier: "ecf-induction",
                                                                   cpd_lead_provider: create(:cpd_lead_provider),
                                                                   user: participant_profile.user)
            end

            it "executes the transfer, returns true and set no errors" do
              expect(form.save).to be_truthy
              expect(form.errors).to be_empty
            end
          end
        end

        context "when some of the historical records are not in the target cohort" do
          let(:historical_school_source_cohort) { create(:school_cohort, cohort: source_cohort) }
          let(:historical_school) { historical_school_source_cohort.school }
          let!(:induction_programme) { create(:induction_programme, :fip, school_cohort: historical_school_source_cohort) }
          let!(:historical_record) { create(:induction_record, participant_profile:, induction_programme:) }
          let!(:historical_lead_provider) { historical_record.lead_provider }
          let!(:historical_delivery_partner) { historical_record.delivery_partner }

          context "when the historical school has not setup the target cohort" do
            it "returns false and set errors" do
              expect(form.save).to be_falsey
              expect(form.errors.first.attribute).to eq(:historical_records)
              expect(form.errors.first.message)
                .to eq("#{target_cohort_start_year} academic year not setup by school #{historical_school.name}")
            end
          end

          context "when the historical school has not setup default induction programme for the target cohort" do
            let!(:historical_school_target_cohort) do
              create(:school_cohort, cohort: target_cohort, school: historical_school)
            end

            before do
              induction_programme.update!(partnership: nil)
            end

            it "returns false and set errors" do
              expect(form.save).to be_falsey
              expect(form.errors.first.attribute).to eq(:historical_records)
              expect(form.errors.first.message)
                .to eq("No default induction programme set for #{target_cohort_start_year} academic year by school #{historical_school.name}")
            end
          end

          context "when the historical school is all setup for the target cohort" do
            let!(:historical_school_target_cohort) do
              create(:school_cohort, :with_induction_programme, cohort: target_cohort, school: historical_school)
            end

            it "moves all the historical records to the target cohort" do
              expect(form.save).to be_truthy
              expect(form.errors).to be_empty

              participant_profile.reload.induction_records.each do |induction_record|
                expect(induction_record.cohort_start_year).to eq(target_cohort_start_year)
              end
            end

            context "when the school is already partnered with the providers" do
              let(:existing_providers_partnership) do
                create(:seed_partnership,
                       school: historical_school,
                       cohort: target_cohort,
                       lead_provider: historical_lead_provider,
                       delivery_partner: historical_delivery_partner)
              end

              before do
                NewSeeds::Scenarios::InductionProgrammes::Fip.new(school_cohort: historical_school_target_cohort)
                                                             .build(default_induction_programme: false)
                                                             .with_partnership(partnership: existing_providers_partnership)
              end

              it "link historical records to the existing partnership" do
                expect(form.save).to be_truthy
                expect(historical_record.reload.partnership).to eq(existing_providers_partnership)
              end
            end

            context "when the school is FIP not partnered with the providers" do
              it "link historical records to a new relationship with the providers" do
                expect(form.save).to be_truthy

                expect(historical_record.reload.partnership).to be_relationship
                expect(historical_record.lead_provider).to eq(historical_lead_provider)
                expect(historical_record.delivery_partner).to eq(historical_delivery_partner)
              end
            end

            context "when the school is not FIP" do
              let!(:induction_programme) { create(:induction_programme, :cip, school_cohort: historical_school_source_cohort) }

              it "link historical records to the default induction programme" do
                expect(form.save).to be_truthy

                expect(historical_record.reload.induction_programme).to eq(historical_school_target_cohort.default_induction_programme)
              end
            end
          end
        end

        context "when some of the induction records are not in the target schedule" do
          let(:historical_school_source_cohort) { create(:school_cohort, cohort: source_cohort) }
          let(:historical_school) { historical_school_source_cohort.school }
          let!(:induction_programme) { create(:induction_programme, school_cohort: historical_school_source_cohort) }
          let!(:historical_record) do
            create(:induction_record,
                   participant_profile:,
                   induction_programme:,
                   schedule: create(:ecf_schedule))
          end

          let(:schedule) { Finance::Schedule::ECF.default_for(cohort: Cohort.current) }

          subject(:form) do
            described_class.new(participant_profile:, source_cohort_start_year:, schedule:)
          end

          before do
            create(:school_cohort, :with_induction_programme, cohort: target_cohort, school: historical_school)
          end

          it "moves all the historical records to the target schedule" do
            expect(form.save).to be_truthy
            expect(form.errors).to be_empty

            participant_profile.reload.induction_records.each do |induction_record|
              expect(induction_record.schedule).to eq(schedule)
            end
          end
        end
      end
    end
  end
end
