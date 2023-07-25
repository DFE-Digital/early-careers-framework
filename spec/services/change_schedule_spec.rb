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

  it "sets the correct attributes to the new participant profile schedule" do
    service.call

    expect(participant_profile.reload.schedule_id).to eq(new_schedule.id)
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
    let(:schedule_identifier) { "ecf-extended-april" }
    let(:course_identifier) { "ecf-induction" }
    let!(:schedule) { create(:ecf_schedule, schedule_identifier: "ecf-extended-april", name: "ECF Standard") }
    let(:new_cohort) { Cohort.next }
    let!(:new_schedule) { create(:ecf_schedule, cohort: new_cohort, schedule_identifier: "ecf-replacement-april", name: "ECF Standard") }

    describe "validations" do
      it_behaves_like "validating a participant for a change schedule"

      it_behaves_like "validating a participant is not already withdrawn for a change schedule" do
        let(:participant_profile) { create(:ect, :withdrawn, lead_provider: cpd_lead_provider.lead_provider) }
      end

      context "when the cohort is changing" do
        let!(:new_schedule) { create(:ecf_schedule, schedule_identifier:, cohort: new_cohort, name: "ECF Standard") }
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
    end
  end

  context "Mentor participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
    let!(:participant_profile) { create(:mentor, lead_provider: cpd_lead_provider.lead_provider, user:) }
    let(:schedule_identifier) { "ecf-extended-april" }
    let(:course_identifier) { "ecf-mentor" }
    let!(:schedule) { create(:ecf_mentor_schedule, schedule_identifier: "ecf-extended-april", name: "Mentor Standard") }
    let(:new_cohort) { Cohort.next }

    describe "validations" do
      it_behaves_like "validating a participant for a change schedule"

      it_behaves_like "validating a participant is not already withdrawn for a change schedule" do
        let(:participant_profile) { create(:mentor, :withdrawn, lead_provider: cpd_lead_provider.lead_provider) }
      end

      context "when the cohort is changing" do
        let!(:new_school_cohort) { create(:school_cohort, :cip, :with_induction_programme, cohort: new_cohort, lead_provider: cpd_lead_provider.lead_provider, school: participant_profile.school) }
        let!(:new_schedule) { create(:ecf_mentor_schedule, schedule_identifier:, cohort: new_cohort, name: "Mentor Standard") }
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
    end
  end

  context "NPQ participant profile" do
    let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
    let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }
    let(:npq_course) { create(:npq_course, identifier: "npq-senior-leadership") }
    let(:schedule) { Finance::Schedule.find_by(schedule_identifier: "npq-specialist-spring") }
    let(:participant_profile) { create(:npq_participant_profile, npq_lead_provider:, npq_course:, schedule:, user:) }
    let(:course_identifier) { npq_course.identifier }
    let(:schedule_identifier) { new_schedule.schedule_identifier }
    let(:new_schedule) { Finance::Schedule.find_by(schedule_identifier: "npq-leadership-spring") }
    let(:new_cohort) { Cohort.next }

    describe "validations" do
      it_behaves_like "validating a participant for a change schedule"

      it_behaves_like "validating a participant is not already withdrawn for a change schedule" do
        let(:participant_profile) { create(:npq_participant_profile, :withdrawn, npq_lead_provider:, npq_course:) }
      end

      context "when the cohort is changing" do
        let(:new_schedule) { Finance::Schedule.find_by(schedule_identifier: "npq-leadership-spring", cohort: new_cohort) }
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
    end

    describe ".call" do
      let(:new_cohort) { Cohort.current }

      describe "when changing the schedule of a participant" do
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

        it "sets the correct attributes to the new participant profile schedule" do
          service.call

          latest_participant_profile_schedule = participant_profile.participant_profile_schedules.last

          expect(latest_participant_profile_schedule).to have_attributes(
            participant_profile_id: participant_profile.id,
            schedule_id: Finance::Schedule.where(schedule_identifier:, cohort: new_cohort).first.id,
          )
        end

        context "when the participant has a different user ID to external ID" do
          let(:participant_identity) { create(:participant_identity, :secondary) }

          it "creates a participant profile schedule" do
            expect { service.call }.to change { ParticipantProfileSchedule.count }
          end
        end
      end

      it "does not update the npq application cohort" do
        expect { service.call }.not_to change(participant_profile.npq_application, :cohort)
      end
    end
  end
end
