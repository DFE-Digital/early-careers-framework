# frozen_string_literal: true

module Mentors
  class Create < BaseService
    include SchoolCohortDelegator
    def call
      ActiveRecord::Base.transaction do
        # TODO: What if email matches but with different name?
        user = User.find_or_create_by!(full_name: full_name, email: email)
        ParticipantProfile::Mentor.create!({ user: user }.merge(mentor_attributes))
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
