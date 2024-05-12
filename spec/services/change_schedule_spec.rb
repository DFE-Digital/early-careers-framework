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

            it "updates the participant profiler school cohort" do
              expect {
                service.call
              }.to change { participant_profile.reload.school_cohort }.to(new_school_cohort)
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

            before do
              create(:npq_statement, :next_output_fee, cpd_lead_provider: npq_lead_provider.cpd_lead_provider, cohort: participant_profile.npq_application.cohort)
              create(:npq_statement, :next_output_fee, cpd_lead_provider: npq_lead_provider.cpd_lead_provider, cohort: new_cohort)
            end

            describe ".call" do
              it_behaves_like "changing the schedule of a participant"
            end

            it "updates the cohort on the npq application" do
              service.call
              expect(participant_profile.npq_application.reload.cohort).to eq(new_cohort)
            end

            context "when moving from a previous cohort" do
              let!(:statement) do
                create(
                  :npq_statement,
                  :next_output_fee,
                  cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
                )
              end

              let!(:new_statement) do
                create(
                  :npq_statement,
                  :next_output_fee,
                  cpd_lead_provider: npq_lead_provider.cpd_lead_provider,
                  cohort: new_cohort,
                )
              end

              it "updates the cohort on the npq application" do
                service.call
                expect(participant_profile.npq_application.reload.cohort).to eq(new_cohort)
              end

              context "when moving from funding cohort to funding cohort" do
                before { FeatureFlag.activate(:npq_capping) }

                let(:participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, schedule:, user:, npq_application:) }
                let(:npq_application) { create(:npq_application, :accepted, npq_lead_provider:, npq_course:, user:, funded_place: false) }

                before do
                  npq_contract.update!(funding_cap: 10)
                  npq_contract_new_cohort.update!(funding_cap: 10)
                end

                it "does not change funding place if original contract has a funded place" do
                  participant_profile.npq_application.update!(funded_place: false, eligible_for_funding: true)

                  service.call

                  expect(participant_profile.reload.npq_application.reload.funded_place).to be_falsey
                end
              end

              context "when moving from non funding cohort to funding cohort" do
                before do
                  npq_contract.update!(funding_cap: 0)
                  npq_contract_new_cohort.update!(funding_cap: 10)
                end

                context "when feature flag `npq_capping` is disabled" do
                  before { FeatureFlag.deactivate(:npq_capping) }

                  it "does not change funding place" do
                    expect { service.call }.not_to change { participant_profile.reload.npq_application.reload.funded_place }
                  end
                end

                context "when feature flag `npq_capping` is enabled" do
                  before do
                    FeatureFlag.activate(:npq_capping)
                  end

                  it "sets funding place to `true` if `eligible_for_funding` is true" do
                    participant_profile.npq_application.update!(eligible_for_funding: true, funded_place: nil)

                    service.call

                    expect(participant_profile.reload.npq_application.reload.funded_place).to be_truthy
                  end

                  it "sets funding place to `false` if `eligible_for_funding` is false" do
                    participant_profile.npq_application.update!(eligible_for_funding: false, funded_place: nil)

                    service.call

                    expect(participant_profile.reload.npq_application.reload.funded_place).to be_falsey
                  end
                end
              end

              context "when moving from funding cohort to non funding cohort" do
                before do
                  FeatureFlag.activate(:npq_capping)

                  npq_contract.update!(funding_cap: 10)
                  npq_contract_new_cohort.update!(funding_cap: 0)
                end

                it "does not change the application to the new cohort" do
                  service.call

                  expect(service.errors.messages_for(:cohort)).to include("The property '#/cohort' cannot be changed")
                end
              end
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
