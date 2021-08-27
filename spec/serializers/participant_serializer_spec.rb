# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantSerializer do
  describe "serialization" do
    let(:mentor_profile) { create(:participant_profile, :mentor) }
    let(:mentor) { mentor_profile.user }
    let(:ect_profile) { create(:participant_profile, :ect, mentor_profile: mentor.mentor_profile) }
    let(:ect) { ect_profile.user }
    let(:ect_cohort) { ect.early_career_teacher_profile.cohort }
    let(:mentor_cohort) { mentor.mentor_profile.cohort }

    context "when the participant is eligible for funding" do
      before do
        eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
        eligibility.eligible_status!
        eligibility = ECFParticipantEligibility.create!(participant_profile: mentor_profile)
        eligibility.eligible_status!
      end

      it "outputs correctly formatted serialized Mentors" do
        expected_json_string = "{\"data\":{\"id\":\"#{mentor.id}\",\"type\":\"participant\",\"attributes\":{\"email\":\"#{mentor.email}\",\"full_name\":\"#{mentor.full_name}\",\"mentor_id\":null,\"school_urn\":\"#{mentor.mentor_profile.school.urn}\",\"participant_type\":\"mentor\",\"cohort\":\"#{mentor_cohort.start_year}\",\"status\":\"active\",\"teacher_reference_number\":\"#{mentor.teacher_profile.trn}\",\"teacher_reference_number_validated\":true,\"eligible_for_funding\":true,\"pupil_premium_uplift\":null,\"sparsity_uplift\":null,\"training_status\":\"active\"}}}"
        expect(ParticipantSerializer.new(mentor).serializable_hash.to_json).to eq expected_json_string
      end

      it "outputs correctly formatted serialized ECTs" do
        expected_json_string = "{\"data\":{\"id\":\"#{ect.id}\",\"type\":\"participant\",\"attributes\":{\"email\":\"#{ect.email}\",\"full_name\":\"#{ect.full_name}\",\"mentor_id\":\"#{mentor.id}\",\"school_urn\":\"#{ect.early_career_teacher_profile.school.urn}\",\"participant_type\":\"ect\",\"cohort\":\"#{ect_cohort.start_year}\",\"status\":\"active\",\"teacher_reference_number\":\"#{ect.teacher_profile.trn}\",\"teacher_reference_number_validated\":true,\"eligible_for_funding\":true,\"pupil_premium_uplift\":null,\"sparsity_uplift\":null,\"training_status\":\"active\"}}}"
        expect(ParticipantSerializer.new(ect).serializable_hash.to_json).to eq expected_json_string
      end
    end

    context "when the participant record is withdrawn" do
      let(:mentor) { create(:participant_profile, :mentor, :withdrawn_record).user }
      let(:ect) { create(:participant_profile, :ect, :withdrawn_record, mentor_profile: mentor.mentor_profile).user }

      it "outputs correctly formatted serialized Mentors" do
        expected_json_string = "{\"data\":{\"id\":\"#{mentor.id}\",\"type\":\"participant\",\"attributes\":{\"email\":null,\"full_name\":null,\"mentor_id\":null,\"school_urn\":null,\"participant_type\":null,\"cohort\":null,\"status\":\"withdrawn\",\"teacher_reference_number\":null,\"teacher_reference_number_validated\":null,\"eligible_for_funding\":null,\"pupil_premium_uplift\":null,\"sparsity_uplift\":null,\"training_status\":null}}}"
        expect(ParticipantSerializer.new(mentor).serializable_hash.to_json).to eq expected_json_string
      end

      it "outputs correctly formatted serialized ECTs" do
        expected_json_string = "{\"data\":{\"id\":\"#{ect.id}\",\"type\":\"participant\",\"attributes\":{\"email\":null,\"full_name\":null,\"mentor_id\":null,\"school_urn\":null,\"participant_type\":null,\"cohort\":null,\"status\":\"withdrawn\",\"teacher_reference_number\":null,\"teacher_reference_number_validated\":null,\"eligible_for_funding\":null,\"pupil_premium_uplift\":null,\"sparsity_uplift\":null,\"training_status\":null}}}"
        expect(ParticipantSerializer.new(ect).serializable_hash.to_json).to eq expected_json_string
      end
    end

    describe "funding_eligibility" do
      context "when there is no eligibility record" do
        it "returns nil" do
          expect(ect_profile.ecf_participant_eligibility).to be_nil

          result = ParticipantSerializer.new(ect).serializable_hash
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

          result = ParticipantSerializer.new(ect).serializable_hash
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

          result = ParticipantSerializer.new(ect).serializable_hash
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

          result = ParticipantSerializer.new(ect).serializable_hash
          expect(result[:data][:attributes][:eligible_for_funding]).to be true
        end
      end
    end

    describe "teacher_reference_number" do
      context "when there is a trn on the teacher profile" do
        it "returns the correct TRN" do
          result = ParticipantSerializer.new(ect).serializable_hash
          expect(result[:data][:attributes][:teacher_reference_number]).to eql ect_profile.teacher_profile.trn
        end
      end

      context "when there is a trn on the validation details" do
        before do
          ect_profile.teacher_profile.update!(trn: nil)
        end
        let!(:validation_data) { create(:ecf_participant_validation_data, participant_profile: ect_profile) }

        it "returns the correct TRN" do
          result = ParticipantSerializer.new(ect).serializable_hash
          expect(result[:data][:attributes][:teacher_reference_number]).to eql validation_data.trn
        end
      end

      context "when there is no TRN" do
        before do
          ect_profile.teacher_profile.update!(trn: nil)
        end

        it "returns nil" do
          result = ParticipantSerializer.new(ect).serializable_hash
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
            result = ParticipantSerializer.new(ect).serializable_hash
            expect(result[:data][:attributes][:teacher_reference_number_validated]).to be true
          end
        end

        context "when the participant is eligible" do
          before do
            eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
            eligibility.eligible_status!
          end

          it "returns true" do
            result = ParticipantSerializer.new(ect).serializable_hash
            expect(result[:data][:attributes][:teacher_reference_number_validated]).to be true
          end
        end

        context "when the participant is in manual check" do
          before do
            eligibility = ECFParticipantEligibility.create!(participant_profile: ect_profile)
            eligibility.manual_check_status!
          end

          it "returns false" do
            result = ParticipantSerializer.new(ect).serializable_hash
            expect(result[:data][:attributes][:teacher_reference_number_validated]).to be false
          end
        end

        context "when the participant has not started validation" do
          it "returns false" do
            result = ParticipantSerializer.new(ect).serializable_hash
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
          result = ParticipantSerializer.new(ect).serializable_hash
          expect(result[:data][:attributes][:teacher_reference_number_validated]).to be false
        end
      end

      context "when there is no TRN" do
        before do
          ect_profile.teacher_profile.update!(trn: nil)
        end

        it "returns nil" do
          result = ParticipantSerializer.new(ect).serializable_hash
          expect(result[:data][:attributes][:teacher_reference_number_validated]).to be_nil
        end
      end
    end
  end
end
