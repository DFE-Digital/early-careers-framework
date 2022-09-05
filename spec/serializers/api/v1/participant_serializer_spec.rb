# frozen_string_literal: true

require "rails_helper"

module Api
  module V1
    RSpec.describe ParticipantSerializer do
      describe "serialization" do
        let(:mentor_profile) { create(:mentor_participant_profile) }
        let(:mentor) { mentor_profile.user }
        let(:ect_profile) { create(:ect_participant_profile, mentor_profile:) }
        let(:ect) { ect_profile.user }
        let(:ect_cohort) { ect.early_career_teacher_profile.cohort }
        let(:mentor_cohort) { mentor.mentor_profile.cohort }

        context "when the participant is eligible for funding" do
          before do
            ECFParticipantEligibility.create!(participant_profile: ect_profile).eligible_status!
            ECFParticipantEligibility.create!(participant_profile: mentor_profile).eligible_status!
          end

          it "outputs correctly formatted serialized Mentors" do
            expected_json_string = "{\"data\":{\"id\":\"#{mentor.id}\",\"type\":\"participant\",\"attributes\":{\"email\":\"#{mentor.email}\",\"full_name\":\"#{mentor.full_name}\",\"mentor_id\":null,\"school_urn\":\"#{mentor.mentor_profile.school.urn}\",\"participant_type\":\"mentor\",\"cohort\":\"#{mentor_cohort.start_year}\",\"status\":\"active\",\"teacher_reference_number\":\"#{mentor.teacher_profile.trn}\",\"teacher_reference_number_validated\":true,\"eligible_for_funding\":true,\"pupil_premium_uplift\":false,\"sparsity_uplift\":false,\"training_status\":\"active\",\"schedule_identifier\":\"ecf-standard-september\",\"updated_at\":\"#{mentor.updated_at.rfc3339}\"}}}"
            expect(ParticipantSerializer.new(mentor_profile).serializable_hash.to_json).to eq expected_json_string
          end

          it "outputs correctly formatted serialized ECTs" do
            expected_json_string = "{\"data\":{\"id\":\"#{ect.id}\",\"type\":\"participant\",\"attributes\":{\"email\":\"#{ect.email}\",\"full_name\":\"#{ect.full_name}\",\"mentor_id\":\"#{mentor.id}\",\"school_urn\":\"#{ect.early_career_teacher_profile.school.urn}\",\"participant_type\":\"ect\",\"cohort\":\"#{ect_cohort.start_year}\",\"status\":\"active\",\"teacher_reference_number\":\"#{ect.teacher_profile.trn}\",\"teacher_reference_number_validated\":true,\"eligible_for_funding\":true,\"pupil_premium_uplift\":false,\"sparsity_uplift\":false,\"training_status\":\"active\",\"schedule_identifier\":\"ecf-standard-september\",\"updated_at\":\"#{ect.updated_at.rfc3339}\"}}}"
            expect(ParticipantSerializer.new(ect_profile).serializable_hash.to_json).to eq expected_json_string
          end
        end

        context "when the participant record is withdrawn" do
          let(:mentor_profile) { create(:mentor_participant_profile, :withdrawn_record) }
          let(:ect_profile) { create(:ect_participant_profile, :withdrawn_record, mentor_profile:) }

          it "outputs correctly formatted serialized Mentors" do
            expected_json = {
              data: {
                id: mentor_profile.user.id,
                type: "participant",
                attributes: {
                  email: mentor_profile.user.email,
                  full_name: mentor_profile.user.full_name,
                  mentor_id: nil,
                  school_urn: mentor_profile.school.urn,
                  participant_type: mentor_profile.participant_type,
                  cohort: mentor_profile.cohort.start_year.to_s,
                  status: "withdrawn",
                  teacher_reference_number: mentor_profile.teacher_profile.trn,
                  teacher_reference_number_validated: false,
                  eligible_for_funding: nil,
                  pupil_premium_uplift: mentor_profile.pupil_premium_uplift,
                  sparsity_uplift: mentor_profile.sparsity_uplift,
                  training_status: mentor_profile.training_status,
                  schedule_identifier: mentor_profile.schedule.schedule_identifier,
                  updated_at: mentor_profile.reload.updated_at.rfc3339,
                },
              },
            }.to_json

            expect(ParticipantSerializer.new(mentor_profile).serializable_hash.to_json).to eql(expected_json)
          end

          it "outputs correctly formatted serialized ECTs" do
            expected_json = {
              data: {
                id: ect_profile.user.id,
                type: "participant",
                attributes: {
                  email: ect_profile.user.email,
                  full_name: ect_profile.user.full_name,
                  mentor_id: ect_profile.mentor.id,
                  school_urn: ect_profile.school.urn,
                  participant_type: ect_profile.participant_type,
                  cohort: ect_profile.cohort.start_year.to_s,
                  status: "withdrawn",
                  teacher_reference_number: ect_profile.teacher_profile.trn,
                  teacher_reference_number_validated: false,
                  eligible_for_funding: nil,
                  pupil_premium_uplift: ect_profile.pupil_premium_uplift,
                  sparsity_uplift: ect_profile.sparsity_uplift,
                  training_status: ect_profile.training_status,
                  schedule_identifier: ect_profile.schedule.schedule_identifier,
                  updated_at: ect_profile.user.updated_at.rfc3339,
                },
              },
            }.to_json

            expect(ParticipantSerializer.new(ect_profile).serializable_hash.to_json).to eql(expected_json)
          end
        end

        describe "funding_eligibility" do
          context "when there is no eligibility record" do
            it "returns nil" do
              expect(ect_profile.ecf_participant_eligibility).to be_nil

              result = ParticipantSerializer.new(ect_profile).serializable_hash
              expect(result[:data][:attributes][:eligible_for_funding]).to be_nil
            end
          end

          context "when the eligibility is manual_check" do
            before do
              eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
              eligibility.manual_check_status!
            end

            it "returns nil" do
              expect(ect_profile.ecf_participant_eligibility.status).to eql "manual_check"

              result = ParticipantSerializer.new(ect_profile).serializable_hash
              expect(result[:data][:attributes][:eligible_for_funding]).to be_nil
            end
          end

          context "when the eligibility is matched" do
            before do
              eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
              eligibility.matched_status!
            end

            it "returns nil" do
              expect(ect_profile.ecf_participant_eligibility.status).to eql "matched"

              result = ParticipantSerializer.new(ect_profile).serializable_hash
              expect(result[:data][:attributes][:eligible_for_funding]).to be_nil
            end
          end

          context "when the eligibility is eligible" do
            before do
              eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
              eligibility.eligible_status!
            end

            it "returns true" do
              expect(ect_profile.ecf_participant_eligibility.status).to eql "eligible"

              result = ParticipantSerializer.new(ect_profile).serializable_hash
              expect(result[:data][:attributes][:eligible_for_funding]).to be true
            end
          end

          context "when the eligibility is ineligible" do
            before do
              eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
              eligibility.ineligible_status!
            end

            it "returns false" do
              expect(ect_profile.ecf_participant_eligibility.status).to eql "ineligible"

              result = ParticipantSerializer.new(ect_profile).serializable_hash
              expect(result[:data][:attributes][:eligible_for_funding]).to be false
            end
          end
        end

        describe "teacher_reference_number" do
          context "when there is a trn on the teacher profile" do
            it "returns the correct TRN" do
              result = ParticipantSerializer.new(ect_profile).serializable_hash
              expect(result[:data][:attributes][:teacher_reference_number]).to eql ect_profile.teacher_profile.trn
            end
          end

          context "when there is a trn on the validation details" do
            before do
              ect_profile.teacher_profile.update!(trn: nil)
            end
            let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: ect_profile) }

            it "returns the correct TRN" do
              result = ParticipantSerializer.new(ect_profile).serializable_hash
              expect(result[:data][:attributes][:teacher_reference_number]).to eql validation_data.trn
            end
          end

          context "when there is no TRN" do
            before do
              ect_profile.teacher_profile.update!(trn: nil)
            end

            it "returns nil" do
              result = ParticipantSerializer.new(ect_profile).serializable_hash
              expect(result[:data][:attributes][:teacher_reference_number]).to be_nil
            end
          end
        end

        describe "teacher_reference_number_validated" do
          context "when there is a trn on the teacher profile" do
            context "when the participant is matched" do
              before do
                eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
                eligibility.matched_status!
              end

              it "returns true" do
                result = ParticipantSerializer.new(ect_profile).serializable_hash
                expect(result[:data][:attributes][:teacher_reference_number_validated]).to be true
              end
            end

            context "when the participant is eligible" do
              before do
                eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
                eligibility.eligible_status!
              end

              it "returns true" do
                result = ParticipantSerializer.new(ect_profile).serializable_hash
                expect(result[:data][:attributes][:teacher_reference_number_validated]).to be true
              end
            end

            context "when the participant is in manual check" do
              before do
                eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
                eligibility.manual_check_status!
              end

              it "returns true" do
                result = ParticipantSerializer.new(ect_profile).serializable_hash
                expect(result[:data][:attributes][:teacher_reference_number_validated]).to be true
              end
            end

            context "when the reason is different_trn" do
              before do
                eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
                eligibility.different_trn_reason!
              end

              it "returns false" do
                result = ParticipantSerializer.new(ect_profile).serializable_hash
                expect(result[:data][:attributes][:teacher_reference_number_validated]).to be false
              end
            end

            context "when the participant has not started validation" do
              it "returns false" do
                result = ParticipantSerializer.new(ect_profile).serializable_hash
                expect(result[:data][:attributes][:teacher_reference_number_validated]).to be false
              end
            end
          end

          context "when there is a trn on the validation details" do
            before do
              ect_profile.teacher_profile.update!(trn: nil)
              create(:ecf_participant_validation_data, participant_profile: ect_profile)
            end

            it "returns false" do
              result = ParticipantSerializer.new(ect_profile).serializable_hash
              expect(result[:data][:attributes][:teacher_reference_number_validated]).to be false
            end
          end

          context "when there is no TRN" do
            before do
              ect_profile.teacher_profile.update!(trn: nil)
            end

            it "returns nil" do
              result = ParticipantSerializer.new(ect_profile).serializable_hash
              expect(result[:data][:attributes][:teacher_reference_number_validated]).to be_nil
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
      end
    end
  end
end
