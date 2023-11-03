# frozen_string_literal: true

module Mentors
  class Reactivate < BaseService
    include SchoolCohortDelegator

    def call
      ActiveRecord::Base.transaction do
        reactivate_participant_profile
        update_participant_profile_email

        ParticipantProfileState.create!(participant_profile:, cpd_lead_provider: induction_programme&.lead_provider&.cpd_lead_provider)

        if induction_programme.present?
          end_current_induction_record

          Induction::Enrol.call(participant_profile:,
                                induction_programme:,
                                start_date:,
                                preferred_email: email)
        end

        Mentors::AddToSchool.call(school: school_cohort.school, mentor_profile: participant_profile)
      end

      participant_profile
    end

  private

    attr_reader :participant_profile, :email, :induction_programme, :school_cohort, :start_date

    def initialize(participant_profile:, induction_programme:, email:, school_cohort:, start_date: nil, **)
      @participant_profile = participant_profile
      @induction_programme = induction_programme || school_cohort.default_induction_programme
      @email = email
      @start_date = start_date
      @school_cohort = school_cohort
    end

    def end_current_induction_record
      latest_induction_record = participant_profile.latest_induction_record
      return unless latest_induction_record.end_date.nil?

      latest_induction_record.changing!(Time.current)
    end

    def reactivate_participant_profile
      participant_profile.update!(
        school_cohort_id: school_cohort.id,
        sparsity_uplift: sparsity_uplift?(start_year),
        pupil_premium_uplift: pupil_premium_uplift?(start_year),
        status: :active,
        schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort.cohort),
      )
    end

    def update_participant_profile_email
      induction_record = participant_profile.latest_induction_record
      return if induction_record.participant_email == email

      Induction::ChangePreferredEmail.call(
        induction_record:,
        preferred_email: email,
      )
    end
  end
end
