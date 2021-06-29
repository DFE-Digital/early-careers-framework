# frozen_string_literal: true

require "rails_helper"

RSpec.describe ParticipantSerializer do
  describe "serialization" do
    let(:cohort) { create :cohort }
    let(:mentor_profile) { create :participant_profile, :mentor, cohort: cohort }
    let(:ect_profile) { create :participant_profile, :ect, mentor_profile: mentor_profile, cohort: cohort }

    it "outputs correctly formatted serialized Mentors" do
      expected_json_string = "{\"data\":{\"id\":\"#{mentor_profile.user.id}\",\"type\":\"participant\",\"attributes\":{\"email\":\"#{mentor_profile.user.email}\",\"full_name\":\"#{mentor_profile.user.full_name}\",\"mentor_id\":null,\"school_urn\":\"#{mentor_profile.school.urn}\",\"participant_type\":\"mentor\",\"cohort\":#{cohort.start_year}}}}"
      expect(ParticipantSerializer.new(mentor_profile.user).serializable_hash.to_json).to eq expected_json_string
    end

    it "outputs correctly formatted serialized ECTs" do
      expected_json_string = "{\"data\":{\"id\":\"#{ect_profile.user_id}\",\"type\":\"participant\",\"attributes\":{\"email\":\"#{ect_profile.user.email}\",\"full_name\":\"#{ect_profile.user.full_name}\",\"mentor_id\":\"#{mentor_profile.user_id}\",\"school_urn\":\"#{ect_profile.school.urn}\",\"participant_type\":\"ect\",\"cohort\":#{cohort.start_year}}}}"
      expect(ParticipantSerializer.new(ect_profile.user).serializable_hash.to_json).to eq expected_json_string
    end
  end
end
