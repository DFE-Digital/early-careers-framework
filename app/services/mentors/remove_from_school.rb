# frozen_string_literal: true

module Mentors
  class RemoveFromSchool < BaseService
    def call
      school.school_mentors.find_by(participant_profile: mentor_profile)&.destroy
    end

  private

    attr_reader :mentor_profile, :school

    def initialize(mentor_profile:, school:)
      @mentor_profile = mentor_profile
      @school = school
    end
  end
end
