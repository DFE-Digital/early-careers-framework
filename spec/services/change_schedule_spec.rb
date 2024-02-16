# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "validating a participant for a change schedule" do
  context "when the schedule is missing" do
    let(:schedule_identifier) {}

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:schedule_identifier)).to include("The property '#/schedule_identifier' must be present and correspond to a valid schedule")
    end
  end

  context "when the course identifier is missing" do
    let(:course_identifier) {}

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:course_identifier)).to include("The entered '#/course_identifier' is not recognised for the given participant. Check details and try again.")
    end
  end

  context "when the course identifier is an invalid value" do
    let(:course_identifier) { "invalid-value" }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:course_identifier)).to include("The entered '#/course_identifier' is not recognised for the given participant. Check details and try again.")
    end
  end

  context "when the participant identifier is missing" do
    let(:participant_id) {}

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
    end
  end

  context "when the participant identifier is an invalid value" do
    let(:participant_id) { "invalid-value" }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
    end
  end

  context "when the schedule identifier change of the same type again" do
    before { described_class.new(params).call }

    it "is invalid and returns an error message" do
      is_expected.to be_invalid

      expect(service.errors.messages_for(:schedule_identifier)).to include("Selected schedule is already on the profile")
    end
  end
end

RSpec.shared_examples "validating a participant is not already withdrawn for a change schedule" do
  it "is invalid and returns an error message" do
    is_expected.to be_invalid

    expect(service.errors.messages_for(:participant_id)).to include("Cannot perform actions on a withdrawn participant")
  end
end

RSpec.shared_examples "changing the schedule of a participant" do
  context "when invalid" do
    let(:params) {}
    it "does not create a new participant profile schedule" do
      expect { service.call }.not_to change { ParticipantProfileSchedule.count }
    end

    it "does not create a new induction record" do
      expect { service.call }.not_to change { InductionRecord.count }
    end
  end

  it "creates a participant profile schedule" do
    expect { service.call }.to change { ParticipantProfileSchedule.count }
  end

  it "sets the correct attributes to the participant profile" do
    service.call

    expect(participant_profile.reload.schedule_id).to eq(new_schedule.id)
  end

  it "sets the correct attributes to the new participant profile schedule" do
    service.call

    latest_participant_profile_schedule = participant_profile.participant_profile_schedules.last

    expect(latest_participant_profile_schedule).to have_attributes(
      participant_profile_id: participant_profile.id,
      schedule_id: Finance::Schedule.find_by(schedule_identifier:, cohort: new_cohort).id,
    )
  end

  context "when the participant has a different user ID to external ID" do
    let(:participant_identity) { create(:participant_identity, :secondary) }

    it "creates a participant profile schedule" do
      expect { service.call }.to change { ParticipantProfileSchedule.count }
    end
  end
end

RSpec.describe ChangeSchedule do
  let(:participant_id) { participant_profile.participant_identity.external_identifier }
  let(:params) do
    {
      cpd_lead_provider:,
      participant_id:,
      course_identifier:,
      schedule_identifier:,
    }
  end
  let(:participant_identity) { create(:participant_identity) }
  let!(:user) { participant_identity.user }

  subject(:service) do
    described_class.new(params)
  end

  context "ECT participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let(:participant_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider, user:) }
    let(:schedule_identifier) { "ecf-standard-september" }
    let(:course_identifier) { "ecf-induction" }
    let!(:schedule) { Finance::Schedule::ECF.find_by(schedule_identifier: "ecf-standard-september") }
    let(:new_cohort) { Cohort.previous }
    let!(:new_schedule) { create(:ecf_schedule, cohort: new_cohort, schedule_identifier: "ecf-replacement-april") }

    describe "validations" do
      it_behaves_like "validating a participant for a change schedule"

      it_behaves_like "validating a participant is not already withdrawn for a change schedule" do
        let(:participant_profile) { create(:ect, :withdrawn, lead_provider: cpd_lead_provider.lead_provider) }
      end

      context "when the cohort is changing" do
        let!(:new_schedule) { Finance::Schedule::ECF.find_by(schedule_identifier:, cohort: new_cohort) }
        let!(:new_school_cohort) { create(:school_cohort, :cip, :with_induction_programme, cohort: new_cohort, lead_provider: cpd_lead_provider.lead_provider, school: participant_profile.school) }
        let(:params) do
          {
            cpd_lead_provider:,
            participant_id:,
            course_identifier:,
            schedule_identifier:,
            cohort: new_cohort.start_year,
          }
        end

        %i[submitted eligible payable paid].each do |state|
          context "when there are #{state} declarations" do
            before { create(:participant_declaration, participant_profile:, state:, course_identifier:, cpd_lead_provider:) }

            context "when changing to another cohort" do
              it "is invalid and returns an error message" do
                is_expected.to be_invalid

                expect(service.errors.messages_for(:cohort)).to include("The property '#/cohort' cannot be changed")
              end
            end
          end
        end

        context "when there are no submitted/eligible/payable/paid declarations" do
          context "when changing to another cohort" do
            describe ".call" do
              it_behaves_like "changing the schedule of a participant"
            end

            it "updates the schedule on the relevant induction record" do
              service.call
              relevant_induction_record = participant_profile.current_induction_record

              expect(relevant_induction_record.schedule).to eq(new_schedule)
            end

            it "updates the induction programme on the relevant induction record" do
              service.call
              relevant_induction_record = participant_profile.current_induction_record

              expect(relevant_induction_record.induction_programme).to eq(new_school_cohort.default_induction_programme)
            end

            it "updates the participant profile school cohort" do
              expect {
                service.call
              }.to change { participant_profile.reload.school_cohort }.to(new_school_cohort)
            end

            context "when some of the historical records are not in the target cohort" do
              let(:historical_school_source_cohort) { create(:school_cohort) }
              let(:historical_school) { historical_school_source_cohort.school }
              let!(:induction_programme) { create(:induction_programme, :fip, school_cohort: historical_school_source_cohort) }
              let!(:historical_record) { create(:induction_record, participant_profile:, induction_programme:) }
              let!(:historical_lead_provider) { historical_record.lead_provider }
              let!(:historical_delivery_partner) { historical_record.delivery_partner }

              context "when the historical school is all setup for the target cohort" do
                let!(:historical_school_target_cohort) do
                  create(:school_cohort, :with_induction_programme, cohort: new_cohort, school: historical_school)
                end

                it "moves all the historical records to the target cohort" do
                  service.call

                  participant_profile.reload.induction_records.active.each do |induction_record|
                    expect(induction_record.cohort_start_year).to eq(new_cohort.start_year)
                  end
                end

                context "when the school is already partnered with the providers" do
                  let(:existing_providers_partnership) do
                    create(:seed_partnership,
                           school: historical_school,
                           cohort: new_cohort,
                           lead_provider: historical_lead_provider,
                           delivery_partner: historical_delivery_partner)
                  end

                  before do
                    NewSeeds::Scenarios::InductionProgrammes::Fip.new(school_cohort: historical_school_target_cohort)
                                                                 .build(default_induction_programme: false)
                                                                 .with_partnership(partnership: existing_providers_partnership)
                  end

                  it "links historical records to the existing partnership" do
                    service.call

                    expect(historical_record.reload.partnership).to eq(existing_providers_partnership)
                  end
                end

                context "when the school is FIP not partnered with the providers" do
                  it "links historical records to a new relationship with the providers" do
                    service.call

                    expect(historical_record.reload.partnership).to be_relationship
                    expect(historical_record.lead_provider).to eq(historical_lead_provider)
                    expect(historical_record.delivery_partner).to eq(historical_delivery_partner)
                  end
                end

                context "when the school is not FIP" do
                  let!(:induction_programme) { create(:induction_programme, :cip, school_cohort: historical_school_source_cohort) }

                  it "links historical records to the default induction programme" do
                    service.call

                    expect(historical_record.reload.induction_programme).to eq(historical_school_target_cohort.default_induction_programme)
                  end
                end
              end

              context "when the historical school is not setup for the target cohort" do
                it "links historical records to a new school cohort in target cohort" do
                  historical_school_cohort = SchoolCohort.find_by(cohort: new_cohort, school: historical_school)
                  expect(historical_school_cohort).to be_nil

                  service.call

                  historical_school_cohort = SchoolCohort.find_by(cohort: new_cohort, school: historical_school)
                  expect(historical_school_cohort).not_to be_nil
                end

                it "moves all the historical records to the target cohort" do
                  service.call

                  participant_profile.reload.induction_records.active.each do |induction_record|
                    expect(induction_record.cohort_start_year).to eq(new_cohort.start_year)
                  end
                end
              end
            end

            context "when some of the induction records are not in the target schedule" do
              let(:historical_school_source_cohort) { create(:school_cohort) }
              let(:historical_school) { historical_school_source_cohort.school }
              let!(:induction_programme) { create(:induction_programme, school_cohort: historical_school_source_cohort) }
              let!(:historical_record) do
                create(:induction_record,
                       participant_profile:,
                       induction_programme:,
                       schedule: create(:ecf_schedule))
              end

              let(:schedule) { Finance::Schedule::ECF.default_for(cohort: Cohort.current) }

              before do
                create(:school_cohort, :with_induction_programme, cohort: new_cohort, school: historical_school)
              end

              it "moves all the other historical records to the target schedule" do
                service.call

                participant_profile.reload.induction_records.active.excluding(historical_record).each do |induction_record|
                  expect(induction_record.schedule).to eq(new_schedule)
                end
              end
            end
          end
        end

        context "when the provider does not have a default partnership with the school in the new cohort" do
          let(:another_lead_provider) { create(:lead_provider) }

          before { participant_profile.school.active_partnerships.find_by(cohort: new_cohort).update(lead_provider: another_lead_provider) }

          it "is invalid and returns an error message" do
            is_expected.to be_invalid

            expect(service.errors.messages_for(:cohort)).to include("You cannot change a participant to this cohort as you do not have a partnership with the school for the cohort. Contact the DfE for assistance.")
          end
        end

        context "when the provider has a challenged partnership with the school in the new cohort" do
          before { participant_profile.school.active_partnerships.find_by(cohort: new_cohort).update(challenge_reason: "mistake") }

          it "is invalid and returns an error message" do
            is_expected.to be_invalid

            expect(service.errors.messages_for(:cohort)).to include("You cannot change a participant to this cohort as you do not have a partnership with the school for the cohort. Contact the DfE for assistance.")
          end
        end

        context "when the provider has a relationship partnership with the school in the new cohort" do
          before { participant_profile.school.active_partnerships.find_by(cohort: new_cohort).update(relationship: true) }

          it "is invalid and returns an error message" do
            is_expected.to be_invalid

            expect(service.errors.messages_for(:cohort)).to include("You cannot change a participant to this cohort as you do not have a partnership with the school for the cohort. Contact the DfE for assistance.")
          end
        end
      end

      context "when the participant does not belong to the CPD lead provider" do
        let(:another_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
        let(:participant_profile) { create(:ect, lead_provider: another_cpd_lead_provider.lead_provider, user:) }

        it "is invalid and returns an error message" do
          is_expected.to be_invalid

          expect(service.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
        end
      end
    end

    describe ".call" do
      let(:new_cohort) { Cohort.current }
      let(:schedule_identifier) { "ecf-replacement-april" }
      let!(:new_schedule) { create(:ecf_schedule, schedule_identifier: "ecf-replacement-april", name: "ECF Standard") }

      it_behaves_like "changing the schedule of a participant"

      it "updates the schedule on the relevant induction record" do
        service.call
        relevant_induction_record = participant_profile.current_induction_record

        expect(relevant_induction_record.schedule).to eq(new_schedule)
      end

      context "when profile schedule is not the same as the induction record" do
        let(:participant_profile) { create(:ect, lead_provider: cpd_lead_provider.lead_provider, schedule:) }

        it "updates the schedule on the relevant induction record" do
          service.call
          relevant_induction_record = participant_profile.current_induction_record

          expect(relevant_induction_record.schedule).to eq(new_schedule)
        end
      end

      it "does not update the participant cohort" do
        expect { service.call }.not_to change { participant_profile.reload.current_induction_record.induction_programme.school_cohort.cohort.start_year }
      end

      context "when participant profile is in a different cohort than the current one" do
        before do
          participant_profile.current_induction_record.induction_programme.school_cohort.update!(cohort: Cohort.previous)
        end

        it "does not update the participant cohort" do
          expect { service.call }.not_to change { participant_profile.reload.current_induction_record.induction_programme.school_cohort.cohort.start_year }
        end
      end

      context "when changing schedule and cohort" do
        let(:schedule_identifier) { "ecf-standard-september" }
        let!(:schedule) { Finance::Schedule::ECF.find_by(schedule_identifier: "ecf-standard-september") }
        let(:new_cohort) { Cohort.previous }
        let!(:new_schedule) { Finance::Schedule::ECF.find_by(schedule_identifier:, cohort: new_cohort) }
        let!(:new_school_cohort) { create(:school_cohort, :cip, :with_induction_programme, cohort: new_cohort, lead_provider: cpd_lead_provider.lead_provider, school: participant_profile.school) }
        let(:params) do
          {
            cpd_lead_provider:,
            participant_id:,
            course_identifier:,
            schedule_identifier:,
            cohort: new_cohort.start_year,
          }
        end

        context "with relationship partnership" do
          before { participant_profile.school.active_partnerships.find_by(cohort: new_cohort).update(relationship: true) }

          it "is invalid and returns an error message" do
            is_expected.to be_invalid

            expect(service.errors.messages_for(:cohort)).to include("You cannot change a participant to this cohort as you do not have a partnership with the school for the cohort. Contact the DfE for assistance.")
          end
        end

        context "without relationship partnership" do
          before { participant_profile.school.active_partnerships.find_by(cohort: new_cohort).update(relationship: false) }

          it "updates the schedule on the relevant induction record" do
            relevant_induction_record = participant_profile.current_induction_record
            expect(relevant_induction_record.schedule).to_not eq(new_schedule)

            service.call

            relevant_induction_record = participant_profile.current_induction_record
            expect(relevant_induction_record.schedule).to eq(new_schedule)
          end
        end
      end

      context "when changing schedule only" do
        let(:cohort) { Cohort.current }
        let!(:new_schedule) { create(:ecf_schedule, cohort:, schedule_identifier: "ecf-replacement-april") }
        let(:params) do
          {
            cpd_lead_provider:,
            participant_id:,
            course_identifier:,
            schedule_identifier: new_schedule.schedule_identifier,
            cohort:,
          }
        end

        context "with relationship partnership" do
          before { participant_profile.school.active_partnerships.find_by(cohort:).update(relationship: true) }

          it "updates the schedule on the relevant induction record" do
            old_relevant_induction_record = participant_profile.current_induction_record
            old_induction_programme = old_relevant_induction_record.induction_programme
            expect(old_relevant_induction_record.schedule).to_not eq(new_schedule)

            service.call

            relevant_induction_record = participant_profile.current_induction_record
            expect(relevant_induction_record.schedule).to eq(new_schedule)

            expect(relevant_induction_record).to_not eq(old_relevant_induction_record)
            expect(relevant_induction_record.induction_programme).to eq(old_induction_programme)
          end
        end

        context "without relationship partnership" do
          before { participant_profile.school.active_partnerships.find_by(cohort:).update(relationship: false) }

          it "updates the schedule on the relevant induction record" do
            old_relevant_induction_record = participant_profile.current_induction_record
            expect(old_relevant_induction_record.schedule).to_not eq(new_schedule)

            target_school_cohort = SchoolCohort.find_by(school: participant_profile.school, cohort:)
            default_induction_programme = target_school_cohort.default_induction_programme

            service.call

            relevant_induction_record = participant_profile.current_induction_record
            expect(relevant_induction_record.schedule).to eq(new_schedule)
            expect(relevant_induction_record.induction_programme).to eq(default_induction_programme)
          end
        end
      end
    end
  end

  context "Mentor participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let!(:participant_profile) { create(:mentor, lead_provider: cpd_lead_provider.lead_provider, user:) }
    let(:schedule_identifier) { "ecf-extended-april" }
    let(:course_identifier) { "ecf-mentor" }
    let(:new_cohort) { Cohort.previous }
    let!(:schedule) { create(:ecf_mentor_schedule, schedule_identifier: "ecf-extended-april") }

    describe "validations" do
      it_behaves_like "validating a participant for a change schedule"

      it_behaves_like "validating a participant is not already withdrawn for a change schedule" do
        let(:participant_profile) { create(:mentor, :withdrawn, lead_provider: cpd_lead_provider.lead_provider) }
      end

      context "when the cohort is changing" do
        let!(:new_school_cohort) { create(:school_cohort, :cip, :with_induction_programme, cohort: new_cohort, lead_provider: cpd_lead_provider.lead_provider, school: participant_profile.school) }
        let!(:new_schedule) { create(:ecf_mentor_schedule, schedule_identifier:, cohort: new_cohort) }
        let(:params) do
          {
            cpd_lead_provider:,
            participant_id:,
            course_identifier:,
            schedule_identifier:,
            cohort: new_cohort.start_year,
          }
        end

        %i[submitted eligible payable paid].each do |state|
          context "when there are #{state} declarations" do
            before { create(:participant_declaration, participant_profile:, state:, course_identifier:, cpd_lead_provider:) }

            context "when changing to another cohort" do
              it "is invalid and returns an error message" do
                is_expected.to be_invalid

                expect(service.errors.messages_for(:cohort)).to include("The property '#/cohort' cannot be changed")
              end
            end
          end
        end

        context "when there are no submitted/eligible/payable/paid declarations" do
          context "when changing to another cohort" do
            describe ".call" do
              it_behaves_like "changing the schedule of a participant"
            end

            it "updates the schedule on the relevant induction record" do
              service.call
              relevant_induction_record = participant_profile.current_induction_record

              expect(relevant_induction_record.schedule).to eq(new_schedule)
            end

            it "updates the induction programme on the relevant induction record" do
              service.call
              relevant_induction_record = participant_profile.current_induction_record

              expect(relevant_induction_record.induction_programme).to eq(new_school_cohort.default_induction_programme)
            end

            it "updates the participant profiler school cohort" do
              expect {
                service.call
              }.to change { participant_profile.reload.school_cohort }.to(new_school_cohort)
            end

            context "when some of the historical records are not in the target cohort" do
              let(:historical_school_source_cohort) { create(:school_cohort) }
              let(:historical_school) { historical_school_source_cohort.school }
              let!(:induction_programme) { create(:induction_programme, :fip, school_cohort: historical_school_source_cohort) }
              let!(:historical_record) { create(:induction_record, participant_profile:, induction_programme:) }
              let!(:historical_lead_provider) { historical_record.lead_provider }
              let!(:historical_delivery_partner) { historical_record.delivery_partner }

              context "when the historical school is all setup for the target cohort" do
                let!(:historical_school_target_cohort) do
                  create(:school_cohort, :with_induction_programme, cohort: new_cohort, school: historical_school)
                end

                it "moves all the historical records to the target cohort" do
                  service.call

                  participant_profile.reload.induction_records.active.each do |induction_record|
                    expect(induction_record.cohort_start_year).to eq(new_cohort.start_year)
                  end
                end

                context "when the school is already partnered with the providers" do
                  let(:existing_providers_partnership) do
                    create(:seed_partnership,
                           school: historical_school,
                           cohort: new_cohort,
                           lead_provider: historical_lead_provider,
                           delivery_partner: historical_delivery_partner)
                  end

                  before do
                    NewSeeds::Scenarios::InductionProgrammes::Fip.new(school_cohort: historical_school_target_cohort)
                                                                 .build(default_induction_programme: false)
                                                                 .with_partnership(partnership: existing_providers_partnership)
                  end

                  it "links historical records to the existing partnership" do
                    service.call

                    expect(historical_record.reload.partnership).to eq(existing_providers_partnership)
                  end
                end

                context "when the school is FIP not partnered with the providers" do
                  it "links historical records to a new relationship with the providers" do
                    service.call

                    expect(historical_record.reload.partnership).to be_relationship
                    expect(historical_record.lead_provider).to eq(historical_lead_provider)
                    expect(historical_record.delivery_partner).to eq(historical_delivery_partner)
                  end
                end

                context "when the school is not FIP" do
                  let!(:induction_programme) { create(:induction_programme, :cip, school_cohort: historical_school_source_cohort) }

                  it "links historical records to the default induction programme" do
                    service.call

                    expect(historical_record.reload.induction_programme).to eq(historical_school_target_cohort.default_induction_programme)
                  end
                end
              end

              context "when the historical school is not setup for the target cohort" do
                it "links historical records to a new school cohort in target cohort" do
                  historical_school_cohort = SchoolCohort.find_by(cohort: new_cohort, school: historical_school)
                  expect(historical_school_cohort).to be_nil

                  service.call

                  historical_school_cohort = SchoolCohort.find_by(cohort: new_cohort, school: historical_school)
                  expect(historical_school_cohort).not_to be_nil
                end

                it "moves all the historical records to the target cohort" do
                  service.call

                  participant_profile.reload.induction_records.active.each do |induction_record|
                    expect(induction_record.cohort_start_year).to eq(new_cohort.start_year)
                  end
                end
              end
            end

            context "when some of the induction records are not in the target schedule" do
              let(:historical_school_source_cohort) { create(:school_cohort) }
              let(:historical_school) { historical_school_source_cohort.school }
              let!(:induction_programme) { create(:induction_programme, school_cohort: historical_school_source_cohort) }
              let!(:historical_record) do
                create(:induction_record,
                       participant_profile:,
                       induction_programme:,
                       schedule: create(:ecf_schedule))
              end

              let(:schedule) { Finance::Schedule::ECF.default_for(cohort: Cohort.current) }

              before do
                create(:school_cohort, :with_induction_programme, cohort: new_cohort, school: historical_school)
              end

              it "moves all the other historical records to the target schedule" do
                service.call

                participant_profile.reload.induction_records.active.excluding(historical_record).each do |induction_record|
                  expect(induction_record.schedule).to eq(new_schedule)
                end
              end
            end
          end
        end

        context "when the provider does not have a default partnership with the school in the new cohort" do
          let(:another_lead_provider) { create(:lead_provider) }

          before { participant_profile.school.active_partnerships.last.update(lead_provider: another_lead_provider) }

          it "is invalid and returns an error message" do
            is_expected.to be_invalid

            expect(service.errors.messages_for(:cohort)).to include("You cannot change a participant to this cohort as you do not have a partnership with the school for the cohort. Contact the DfE for assistance.")
          end
        end

        context "when the provider has a challenged partnership with the school in the new cohort" do
          before { participant_profile.school.active_partnerships.find_by(cohort: new_cohort).update(challenge_reason: "mistake") }

          it "is invalid and returns an error message" do
            is_expected.to be_invalid

            expect(service.errors.messages_for(:cohort)).to include("You cannot change a participant to this cohort as you do not have a partnership with the school for the cohort. Contact the DfE for assistance.")
          end
        end

        context "when the provider has a relationship partnership with the school in the new cohort" do
          before { participant_profile.school.active_partnerships.find_by(cohort: new_cohort).update(relationship: true) }

          it "is invalid and returns an error message" do
            is_expected.to be_invalid

            expect(service.errors.messages_for(:cohort)).to include("You cannot change a participant to this cohort as you do not have a partnership with the school for the cohort. Contact the DfE for assistance.")
          end
        end
      end

      context "when the participant does not belong to the CPD lead provider" do
        let(:another_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
        let(:participant_profile) { create(:mentor, lead_provider: another_cpd_lead_provider.lead_provider, user:) }

        it "is invalid and returns an error message" do
          is_expected.to be_invalid

          expect(service.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
        end
      end
    end

    describe ".call" do
      let(:new_cohort) { Cohort.current }
      let(:schedule_identifier) { "ecf-replacement-april" }
      let!(:new_schedule) { create(:ecf_mentor_schedule, schedule_identifier: "ecf-replacement-april", name: "Mentor Standard") }

      it_behaves_like "changing the schedule of a participant"

      it "updates the schedule on the relevant induction record" do
        service.call
        relevant_induction_record = participant_profile.current_induction_record

        expect(relevant_induction_record.schedule).to eq(new_schedule)
      end

      context "when profile schedule is not the same as the induction record" do
        before { participant_profile.update!(schedule:) }

        it "updates the schedule on the relevant induction record" do
          service.call
          relevant_induction_record = participant_profile.current_induction_record

          expect(relevant_induction_record.schedule).to eq(new_schedule)
        end
      end

      it "does not update the participant cohort" do
        expect { service.call }.not_to change { participant_profile.reload.current_induction_record.induction_programme.school_cohort.cohort.start_year }
      end

      context "when participant profile is in a different cohort than the current one" do
        before do
          participant_profile.current_induction_record.induction_programme.school_cohort.update!(cohort: Cohort.previous)
        end

        it "does not update the participant cohort" do
          expect { service.call }.not_to change { participant_profile.reload.current_induction_record.induction_programme.school_cohort.cohort.start_year }
        end
      end
    end
  end

  context "NPQ participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
    let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
    let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
    let(:schedule) { Finance::Schedule::NPQ.find_by(cohort: Cohort.current, schedule_identifier: "npq-specialist-spring") }
    let(:participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, schedule:, user:) }
    let(:course_identifier) { npq_course.identifier }
    let(:schedule_identifier) { new_schedule.schedule_identifier }
    let(:new_cohort) { Cohort.previous }
    let(:new_schedule) { Finance::Schedule::NPQ.find_by(cohort: new_cohort, schedule_identifier: "npq-leadership-spring") }
    let!(:npq_contract) { create(:npq_contract, :npq_senior_leadership, npq_lead_provider:, npq_course:) }

    describe "validations" do
      it_behaves_like "validating a participant for a change schedule"

      it_behaves_like "validating a participant is not already withdrawn for a change schedule" do
        let(:participant_profile) { create(:npq_participant_profile, :withdrawn, npq_lead_provider:, npq_course:) }
      end

      context "when the cohort is changing" do
        let!(:npq_contract_new_cohort) { create(:npq_contract, :npq_senior_leadership, cohort: new_cohort, npq_lead_provider:, npq_course:) }
        let(:new_schedule) { Finance::Schedule::NPQ.find_by(schedule_identifier: "npq-leadership-spring", cohort: new_cohort) }
        let(:params) do
          {
            cpd_lead_provider:,
            participant_id:,
            course_identifier:,
            schedule_identifier:,
            cohort: new_cohort.start_year,
          }
        end

        %i[submitted eligible payable paid].each do |state|
          context "when there are #{state} declarations" do
            before { create(:participant_declaration, participant_profile:, state:, course_identifier:, cpd_lead_provider:) }

            context "when changing to another cohort" do
              let(:new_cohort) { Cohort.previous }

              it "is invalid and returns an error message" do
                is_expected.to be_invalid

                expect(service.errors.messages_for(:cohort)).to include("The property '#/cohort' cannot be changed")
              end
            end
          end
        end

        context "when there are no submitted/eligible/payable/paid declarations" do
          context "when changing to another cohort" do
            let(:new_cohort) { Cohort.previous }

            describe ".call" do
              it_behaves_like "changing the schedule of a participant"
            end

            it "updates the cohort on the npq application" do
              service.call
              expect(participant_profile.npq_application.cohort).to eq(new_cohort)
            end
          end
        end
      end

      context "when the participant does not belong to the CPD lead provider" do
        let(:another_cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }
        let(:another_npq_lead_provider) { another_cpd_lead_provider.npq_lead_provider }
        let(:participant_profile) { create(:npq_participant_profile, npq_lead_provider: another_npq_lead_provider) }

        it "is invalid and returns an error message" do
          is_expected.to be_invalid

          expect(service.errors.messages_for(:participant_id)).to include("Your update cannot be made as the '#/participant_id' is not recognised. Check participant details and try again.")
        end
      end

      context "when lead provider has no contract for the cohort and course" do
        let(:new_cohort) { Cohort.previous }

        before { npq_contract.update!(npq_course: create(:npq_specialist_course)) }

        it "is invalid and returns an error message" do
          is_expected.to be_invalid

          expect(service.errors.messages_for(:cohort)).to include("You cannot change a participant to this cohort as you do not have a contract for the cohort and course. Contact the DfE for assistance.")
        end
      end
    end

    describe ".call" do
      let(:new_cohort) { Cohort.current }

      it_behaves_like "changing the schedule of a participant"

      it "does not update the npq application cohort" do
        expect { service.call }.not_to change { participant_profile.reload.npq_application.cohort.start_year }
      end

      context "when participant profile is in a different cohort than the current one" do
        before do
          participant_profile.schedule.update!(cohort: Cohort.previous)
        end

        it "does not update the participant profile cohort" do
          expect { service.call }.not_to change { participant_profile.reload.schedule.cohort.start_year }
        end
      end
    end
  end
end
