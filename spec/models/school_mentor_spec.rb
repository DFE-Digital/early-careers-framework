# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolMentor, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:participant_profile) }
    it { is_expected.to belong_to(:preferred_identity) }
  end

  describe ".to_be_removed" do
    let(:mentor_profiles) { create_list(:mentor_participant_profile, 4) }

    before do
      mentor_profiles.each do |mentor_profile|
        Mentors::AddToSchool.call(mentor_profile:, school: mentor_profile.school)
      end
      mentor_profiles[1].school_mentors.first.update!(remove_from_school_on: 1.day.ago)
      mentor_profiles[2].school_mentors.first.update!(remove_from_school_on: Time.zone.today)
      mentor_profiles[3].school_mentors.first.update!(remove_from_school_on: 1.day.from_now)
    end

    it "returns records that have a removed_from_school_on date <= today" do
      expected_school_mentors = mentor_profiles[1..2].map { |mp| mp.school_mentors.first }
      expect(described_class.to_be_removed).to match_array expected_school_mentors
    end
  end
end
