# frozen_string_literal: true

module Mentors
  class AddToSchool< BaseService
    def call
      SchoolMentor.find_or_create_by!(participant_profile: mentor_profile, school: school) do |record|
        record.preferred_identity = preferred_identity
      end
    end

  private

    attr_reader :mentor_profile, :school, :preferred_identity

    def initialize(mentor_profile:, school:, preferred_identity: nil)
      @mentor_profile = mentor_profile
      @school = school
      @preferred_identity = preferred_identity || mentor_profile.participant_identity
    end
  end
end
