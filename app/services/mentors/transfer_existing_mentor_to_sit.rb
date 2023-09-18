# frozen_string_literal: true

module Mentors
  class TransferExistingMentorToSit < BaseService
    include SchoolCohortDelegator

    def call
      ActiveRecord::Base.transaction do
        mentor_user = mentor_profile.user
        Identity::Transfer.call(from_user: sit_user, to_user: mentor_user)
        Induction::Enrol.call(participant_profile: mentor_profile, induction_programme: school_cohort.default_induction_programme, start_date:)
        Mentors::AddToSchool.call(mentor_profile:, school: school_cohort.school)
        sit_user.reload.destroy!
        mentor_profile.reload
      end
    end

  private

    attr_reader :sit_user, :mentor_profile, :school_cohort, :start_date

    def initialize(sit_user:, mentor_profile:, school_cohort:, start_date:)
      @sit_user = sit_user
      @mentor_profile = mentor_profile
      @school_cohort = school_cohort
      @start_date = start_date
    end
  end
end
