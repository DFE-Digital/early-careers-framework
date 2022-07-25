# frozen_string_literal: true

require "rails_helper"

module Api
  module V1
    RSpec.describe ParticipantSerializer do
      describe "serialization" do
        let(:lead_provider)       { create(:cpd_lead_provider, :with_lead_provider).lead_provider }
        let(:partnership)         { create(:partnership, lead_provider:) }
        let(:cohort)              { partnership.cohort }
        let(:induction_programme) { create(:induction_programme, partnership:) }
        let(:school_cohort)       { create(:school_cohort, school: partnership.school, cohort:, induction_programme_choice: "full_induction_programme") }

        let(:ect_cohort)     { ect.early_career_teacher_profile.cohort }
        let(:mentor_cohort)  { mentor.mentor_profile.cohort }

        subject { ParticipantSerializer.new(participant_profile, params: { lead_provider: }) }

        context "when the participant is eligible for funding" do
          def expected_json_string(participant_profile, status: "active")
            user = participant_profile.user
            "{\"data\":{\"id\":\"#{user.id}\",\"type\":\"participant\",\"attributes\":{\"email\":\"#{user.email}\",\"full_name\":\"#{user.full_name}\",\"mentor_id\":#{participant_profile.mentor_id.to_json},\"school_urn\":\"#{participant_profile.current_induction_record.school.urn}\",\"participant_type\":\"#{participant_profile.participant_type}\",\"cohort\":\"#{school_cohort.start_year}\",\"status\":\"#{status}\",\"teacher_reference_number\":\"#{user.teacher_profile.trn}\",\"teacher_reference_number_validated\":true,\"eligible_for_funding\":true,\"pupil_premium_uplift\":false,\"sparsity_uplift\":false,\"training_status\":\"active\",\"schedule_identifier\":\"ecf-standard-september\",\"updated_at\":\"#{user.updated_at.rfc3339}\"}}}"
          end
          let(:participant_profile) { create(:mentor_participant_profile) }

          before do
            Induction::Enrol.call(participant_profile:, induction_programme:)
            ECFParticipantEligibility.create!(participant_profile:).eligible_status!
          end

          context "with a mentor profile" do
            it "outputs correctly formatted serialized Mentors" do
              expect(subject.serializable_hash.to_json).to eq expected_json_string(participant_profile)
            end

            context "when the participant record is withdrawn" do
              before { participant_profile.current_induction_record.withdrawn_induction_status! }

              it "outputs correctly formatted serialized Mentors" do
                expected_json = {
                  data: {
                    id: participant_profile.user_id,
                    type: "participant",
                    attributes: {
                      email: nil,
                      full_name: participant_profile.user.full_name,
                      mentor_id: nil,
                      school_urn: participant_profile.induction_records.latest.school.urn,
                      participant_type: "mentor",
                      cohort: cohort.start_year.to_s,
                      status: "withdrawn",
                      teacher_reference_number: participant_profile.teacher_profile.trn,
                      teacher_reference_number_validated: true,
                      eligible_for_funding: true,
                      pupil_premium_uplift: participant_profile.pupil_premium_uplift,
                      sparsity_uplift: participant_profile.sparsity_uplift,
                      training_status: participant_profile.training_status,
                      schedule_identifier: participant_profile.schedule.schedule_identifier,
                      updated_at: participant_profile.updated_at.rfc3339,
                    },
                  },
                }.to_json

                expect(subject.serializable_hash.to_json).to eq expected_json
              end
            end
          end

          context "with an ect profile" do
            let(:participant_profile) { create(:ect_participant_profile, :ecf_participant_validation_data) }

            it "outputs correctly formatted serialized ECTs" do
              expect(subject.serializable_hash.to_json).to eq expected_json_string(participant_profile)
            end

            describe "participant eligibility" do
              let(:eligible_for_funding)               { subject.serializable_hash.dig(:data, :attributes, :eligible_for_funding) }
              let(:teacher_reference_number_validated) { subject.serializable_hash.dig(:data, :attributes, :teacher_reference_number_validated) }
              context "when there is no eligibility record" do
                before do
                  participant_profile.ecf_participant_eligibility.destroy!
                  participant_profile.reload
                end

                it "eligible_for_funding is nil" do
                  expect(participant_profile.reload.ecf_participant_eligibility).to be_nil
                  expect(eligible_for_funding).to be_nil
                end

                it "teacher_reference_number_validated is false" do
                  expect(teacher_reference_number_validated).to be false
                end
              end

              context "when the eligibility is manual_check" do
                before do
                  participant_profile.ecf_participant_eligibility.manual_check_status!
                end

                it "returns nil" do
                  expect(participant_profile.ecf_participant_eligibility).to be_manual_check_status

                  expect(eligible_for_funding).to be_nil
                end

                it "teacher_reference_number_validated is true" do
                  expect(teacher_reference_number_validated).to be true
                end
              end

              context "when the eligibility is matched" do
                before do
                  participant_profile.ecf_participant_eligibility.matched_status!
                end

                it "eligible_for_funding returns nil" do
                  expect(participant_profile.ecf_participant_eligibility).to be_matched_status

                  expect(eligible_for_funding).to be_nil
                end

                it "teacher_reference_number_validated is true" do
                  expect(teacher_reference_number_validated).to be true
                end
              end

              context "when the eligibility is eligible" do
                before do
                  participant_profile.ecf_participant_eligibility.eligible_status!
                end

                it "eligible_for_funding returns true" do
                  expect(participant_profile.ecf_participant_eligibility).to be_eligible_status

                  expect(eligible_for_funding).to be true
                end

                it "teacher_reference_number_validated is true" do
                  expect(teacher_reference_number_validated).to be true
                end
              end

              context "when the eligibility is ineligible" do
                before do
                  participant_profile.ecf_participant_eligibility.ineligible_status!
                  participant_profile.ecf_participant_eligibility.different_trn_reason!
                end

                it "eligible_for_funding returns false" do
                  expect(participant_profile.ecf_participant_eligibility).to be_ineligible_status

                  expect(eligible_for_funding).to be false
                end

                it "teacher_reference_number_validated returns false" do
                  expect(teacher_reference_number_validated).to be false
                end
              end
            end

            describe "#teacher_reference_number" do
              let(:teacher_reference_number)           { subject.serializable_hash.dig(:data, :attributes, :teacher_reference_number) }
              let(:teacher_reference_number_validated) { subject.serializable_hash.dig(:data, :attributes, :teacher_reference_number_validated) }

              context "when there is a trn on the teacher profile" do
                it "returns the correct TRN" do
                  expect(teacher_reference_number).to eq(participant_profile.teacher_profile.trn)
                end
              end

              context "when there is a trn on the validation details" do
                before { participant_profile.teacher_profile.update!(trn: nil) }

                it "returns the correct TRN" do
                  expect(teacher_reference_number).to eq(participant_profile.ecf_participant_validation_data.trn)
                end

                it "teacher_reference_number_validated returns true" do
                  expect(teacher_reference_number_validated).to be true
                end
              end

              context "when there is no TRN" do
                before do
                  participant_profile.teacher_profile.update!(trn: nil)
                  participant_profile.ecf_participant_validation_data.destroy!
                  participant_profile.reload
                end

                it "teacher_reference_number returns nil" do
                  expect(teacher_reference_number).to be_nil
                end

                it "teacher_reference_number_validated returns nil" do
                  expect(teacher_reference_number_validated).to be nil
                end
              end
            end
          end
        end

        describe "pupil_premium_uplift" do
          let(:result) { ParticipantSerializer.new(ect_profile).serializable_hash }

          context "when participant belongs to a school" do
            context "eligible pupil premium uplift" do
              before { ect_profile.update!(pupil_premium_uplift: true) }

              it "returns true" do
                expect(result[:data][:attributes][:pupil_premium_uplift]).to be true
              end
            end

            context "not eligible pupil premium uplift" do
              before { ect_profile.update!(pupil_premium_uplift: false) }

              it "returns false" do
                expect(result[:data][:attributes][:pupil_premium_uplift]).to be false
              end
            end

            context "eligible sparsity uplift" do
              before { ect_profile.update!(sparsity_uplift: true) }

              it "returns true" do
                expect(result[:data][:attributes][:sparsity_uplift]).to be true
              end
            end

            context "not eligible sparsity uplift" do
              before { ect_profile.update!(sparsity_uplift: false) }

              it "returns false" do
                expect(result[:data][:attributes][:sparsity_uplift]).to be false
              end
            end
          end
        end

        context "when training_status is withdrawn" do
          subject { ParticipantSerializer.new(ect_profile) }

          let(:ect_profile) { create(:ect_participant_profile, training_status: "withdrawn") }

          it "nullifies email" do
            expect(subject.serializable_hash[:data][:attributes][:email]).to be_nil
          end
        end
      end
    end
  end
end
