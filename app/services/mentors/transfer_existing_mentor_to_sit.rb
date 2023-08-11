# frozen_string_literal: true

module Mentors
  class TransferExistingMentorToSit < BaseService
    include SchoolCohortDelegator

    def call
      mentor_user = mentor_profile.user
      Identity::Transfer.call(from_user: mentor_user, to_user: sit_user)
      mentor_user.destroy!
      mentor_profile.reload

      ParticipantProfileState.create!(participant_profile: mentor_profile, cpd_lead_provider: school_cohort&.default_induction_programme&.lead_provider&.cpd_lead_provider)
      if school_cohort.default_induction_programme.present?
        Induction::Enrol.call(participant_profile: mentor_profile,
                              induction_programme: school_cohort.default_induction_programme,
                              start_date:)
      end
      Mentors::AddToSchool.call(school: school_cohort.school, mentor_profile:)

      mentor_profile
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
