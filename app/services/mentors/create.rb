# frozen_string_literal: true

module Mentors
  class Create < BaseService
    include SchoolCohortDelegator

    def call
      ActiveRecord::Base.transaction do
        # NOTE: This will not update the full_name if the user has an active participant profile,
        # the scenario I am working on is enabling a NPQ user to be added as a mentor
        # Not matching on full_name means this works more smoothly for the end user
        # and they don't get "email already in use" errors if they spell the name differently
        user = User.find_or_create_by!(email: email) do |mentor|
          mentor.full_name = full_name
        end
        user.update!(full_name: full_name) unless user.teacher_profile&.participant_profiles&.active_record&.any?

        teacher_profile = TeacherProfile.find_or_create_by!(user: user) do |profile|
          profile.school = school_cohort.school
        end

        ParticipantProfile::Mentor.create!({ teacher_profile: teacher_profile, schedule: Finance::Schedule.default }.merge(mentor_attributes)) do |mentor_profile|
          ParticipantProfileState.create!(participant_profile: mentor_profile)
          Analytics::ECFValidationService.upsert_record(mentor_profile)
        end
      end
    end

  private

    attr_reader :full_name, :email, :school_cohort

    def initialize(full_name:, email:, school_cohort:, **)
      @full_name = full_name
      @email = email
      @school_cohort = school_cohort
    end

    def mentor_attributes
      {
        school_cohort_id: school_cohort.id,
        sparsity_uplift: sparsity_uplift?(start_year),
        pupil_premium_uplift: pupil_premium_uplift?(start_year),
      }
    end
  end
end
