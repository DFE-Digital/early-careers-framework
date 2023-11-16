# frozen_string_literal: true

module EarlyCareerTeachers
  class Reactivate < BaseService
    include SchoolCohortDelegator

    def call
      ActiveRecord::Base.transaction do
        reactivate_participant_profile
        update_participant_profile_email

        ParticipantProfileState.create!(participant_profile:,
                                        cpd_lead_provider: induction_programme&.lead_provider&.cpd_lead_provider)

        if induction_programme.present?
          end_current_induction_record

          Induction::Enrol.call(participant_profile:,
                                induction_programme:,
                                mentor_profile:,
                                start_date:,
                                appropriate_body_id:,
                                preferred_email: email)
        end
      end

      participant_profile
    end

  private

    attr_reader :participant_profile, :email, :induction_programme, :school_cohort, :mentor_profile_id,
                :start_date, :appropriate_body_id, :induction_start_date

    def initialize(participant_profile:, email:, school_cohort:, mentor_profile_id: nil, start_date: nil, appropriate_body_id: nil, induction_start_date: nil)
      @participant_profile = participant_profile
      @email = email
      @school_cohort = school_cohort
      @mentor_profile_id = mentor_profile_id
      @start_date = start_date
      @appropriate_body_id = appropriate_body_id
      @induction_start_date = induction_start_date
      @induction_programme = school_cohort.default_induction_programme
    end

    def mentor_profile
      ParticipantProfile::Mentor.find(mentor_profile_id) if mentor_profile_id.present?
    end

    def end_current_induction_record
      latest_induction_record = participant_profile.latest_induction_record
      return unless latest_induction_record.end_date.nil?

      latest_induction_record.changing!(Time.current)
    end

    def reactivate_participant_profile
      participant_profile.update!(
        school_cohort_id: school_cohort.id,
        mentor_profile_id:,
        sparsity_uplift: sparsity_uplift?(start_year),
        pupil_premium_uplift: pupil_premium_uplift?(start_year),
        induction_start_date:,
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
