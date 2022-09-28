# frozen_string_literal: true

module Mentors
  class AddProfileToECT < BaseService
    include SchoolCohortDelegator

    def call
      check_no_mentor_profiles_exist!

      mentor_profile = nil

      ActiveRecord::Base.transaction do
        mentor_profile = ParticipantProfile::Mentor.create!(
          teacher_profile: ect_profile.teacher_profile,
          participant_identity: ect_profile.participant_identity,
          schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort.cohort),
          sparsity_uplift: sparsity_uplift?(start_year),
          pupil_premium_uplift: pupil_premium_uplift?(start_year),
          school_cohort:,
          start_term:,
        )

        ParticipantProfileState.create!(participant_profile: mentor_profile,
                                        cpd_lead_provider: school_cohort&.default_induction_programme&.lead_provider&.cpd_lead_provider)

        if school_cohort.default_induction_programme.present?
          Induction::Enrol.call(participant_profile: mentor_profile,
                                induction_programme: school_cohort.default_induction_programme,
                                preferred_email:,
                                start_date:)
        end

        Mentors::AddToSchool.call(school: school_cohort.school, mentor_profile:, preferred_email:)

        validate! mentor_profile
      end

      mentor_profile
    end

  private

    attr_reader :ect_profile, :preferred_email, :start_term, :school_cohort, :start_date

    def initialize(ect_profile:, school_cohort:, preferred_email: nil, start_term: nil, start_date: nil)
      @ect_profile = ect_profile
      @preferred_email = preferred_email || ect_profile.participant_identity.email
      @start_term = start_term || school_cohort.cohort.start_term_options.first
      @start_date = start_date
      @school_cohort = school_cohort
    end

    def validate!(mentor_profile)
      return if ect_profile.ecf_participant_validation_data.blank?

      validation_data = ect_profile.ecf_participant_validation_data.dup
      validation_data.participant_profile = mentor_profile
      validation_data.save!

      Participants::ParticipantValidationForm.call(mentor_profile)
    end

    def check_no_mentor_profiles_exist!
      raise "Mentor profile exists" if ect_profile.teacher_profile.ecf_profiles.mentors.any?
    end

    def start_year
      @start_year ||= school_cohort.cohort.start_year
    end
  end
end
