# frozen_string_literal: true

module Mentors
  class Create < BaseService
    include SchoolCohortDelegator
    def call
      ActiveRecord::Base.transaction do
        # NOTE: This will not update the full_name if the user exists, the scenario
        # I am working on is enabling a NPQ user to be added as a mentor
        # Not matching on full_name means this works more smoothly for the end user
        # and they don't get "email already in use" errors if they spell the name
        # differently
        user = User.find_or_create_by!(email: email) do |mentor|
          mentor.full_name = full_name
        end
        ParticipantProfile::Mentor.create!({ user: user }.merge(mentor_attributes))
      end
    end

  private

    attr_reader :full_name, :email, :cohort_id, :school_id

    def initialize(full_name:, email:, cohort_id:, school_id:, **)
      @full_name = full_name
      @email = email
      @cohort_id = cohort_id
      @school_id = school_id
    end

    def mentor_attributes
      {
        school_id: school_id,
        cohort_id: cohort_id,
        sparsity_uplift: sparsity_uplift?(start_year),
        pupil_premium_uplift: pupil_premium_uplift?(start_year),
      }
    end
  end
end
