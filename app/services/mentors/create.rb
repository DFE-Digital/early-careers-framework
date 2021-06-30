# frozen_string_literal: true

module Mentors
  class Create < BaseService
    include SchoolCohortDelegator
    def call
      ActiveRecord::Base.transaction do
        # TODO: What if email matches but with different name?
        user = User.find_or_create_by!(full_name: full_name, email: email)
        MentorProfile.create!({ user: user }.merge(mentor_attributes))
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
