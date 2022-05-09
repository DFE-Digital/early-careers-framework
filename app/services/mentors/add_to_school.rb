# frozen_string_literal: true

module Mentors
  class AddToSchool < BaseService
    def call
      SchoolMentor.find_or_create_by!(participant_profile: mentor_profile, school: school) do |record|
        record.preferred_identity = preferred_identity
      end
    end

  private

    attr_reader :mentor_profile, :school, :preferred_email

    def initialize(mentor_profile:, school:, preferred_email: nil)
      @mentor_profile = mentor_profile
      @school = school
      @preferred_email = preferred_email
    end

    def preferred_identity
      if preferred_email.blank?
        mentor_profile.participant_identity
      else
        Identity::Create.call(user: mentor_profile.participant_identity.user,
                              email: preferred_email)
      end
    end
  end
end
