# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantSerializer do
  describe "serialization" do
    let(:mentor) { create(:participant_profile, :mentor).user }
    let(:ect) { create(:participant_profile, :ect, mentor_profile: mentor.mentor_profile).user }
    let(:ect_cohort) { ect.early_career_teacher_profile.cohort }
    let(:mentor_cohort) { mentor.mentor_profile.cohort }

    it "outputs correctly formatted serialized Mentors" do
      expected_json_string = "{\"data\":{\"id\":\"#{mentor.id}\",\"type\":\"participant\",\"attributes\":{\"email\":\"#{mentor.email}\",\"full_name\":\"#{mentor.full_name}\",\"mentor_id\":null,\"school_urn\":\"#{mentor.mentor_profile.school.urn}\",\"participant_type\":\"mentor\",\"cohort\":#{mentor_cohort.start_year},\"status\":\"active\"}}}"
      expect(ParticipantSerializer.new(mentor).serializable_hash.to_json).to eq expected_json_string
    end

    it "outputs correctly formatted serialized ECTs" do
      expected_json_string = "{\"data\":{\"id\":\"#{ect.id}\",\"type\":\"participant\",\"attributes\":{\"email\":\"#{ect.email}\",\"full_name\":\"#{ect.full_name}\",\"mentor_id\":\"#{mentor.id}\",\"school_urn\":\"#{ect.early_career_teacher_profile.school.urn}\",\"participant_type\":\"ect\",\"cohort\":#{ect_cohort.start_year},\"status\":\"active\"}}}"
      expect(ParticipantSerializer.new(ect).serializable_hash.to_json).to eq expected_json_string
    end

    context "when the participant is withdrawn" do
      let(:mentor) { create(:participant_profile, :mentor, status: "withdrawn").user }
      let(:ect) { create(:participant_profile, :ect, mentor_profile: mentor.mentor_profile, status: "withdrawn").user }

      it "outputs correctly formatted serialized Mentors" do
        expected_json_string = "{\"data\":{\"id\":\"#{mentor.id}\",\"type\":\"participant\",\"attributes\":{\"email\":null,\"full_name\":null,\"mentor_id\":null,\"school_urn\":null,\"participant_type\":null,\"cohort\":null,\"status\":\"withdrawn\"}}}"
        expect(ParticipantSerializer.new(mentor).serializable_hash.to_json).to eq expected_json_string
      end

      it "outputs correctly formatted serialized ECTs" do
        expected_json_string = "{\"data\":{\"id\":\"#{ect.id}\",\"type\":\"participant\",\"attributes\":{\"email\":null,\"full_name\":null,\"mentor_id\":null,\"school_urn\":null,\"participant_type\":null,\"cohort\":null,\"status\":\"withdrawn\"}}}"
        expect(ParticipantSerializer.new(ect).serializable_hash.to_json).to eq expected_json_string
      end
    end
  end
end
