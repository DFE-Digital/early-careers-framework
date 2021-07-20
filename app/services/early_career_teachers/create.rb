# frozen_string_literal: true

module EarlyCareerTeachers
  class Create < BaseService
    include SchoolCohortDelegator
    def call
      ActiveRecord::Base.transaction do
        # TODO: What if email matches but with different name?
        user = User.find_or_create_by!(full_name: full_name, email: email)
        ParticipantProfile::ECT.create!({ user: user }.merge(ect_attributes))
      end
    end

  private

    attr_reader :full_name, :email, :school_cohort, :mentor_profile_id

    def initialize(full_name:, email:, school_cohort:, mentor_profile_id: nil)
      @full_name = full_name
      @email = email
      @school_cohort = school_cohort
      @mentor_profile_id = mentor_profile_id
    end

    def ect_attributes
      {
        school_cohort_id: school_cohort.id,
        mentor_profile_id: mentor_profile_id,
        sparsity_uplift: sparsity_uplift?(start_year),
        pupil_premium_uplift: pupil_premium_uplift?(start_year),
      }
    end
  end
end
