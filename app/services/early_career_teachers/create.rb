# frozen_string_literal: true

module EarlyCareerTeachers
  class Create < BaseService
    include SchoolCohortDelegator
    ParticipantProfileExistsError = Class.new(RuntimeError)

    def call
      profile = nil
      ActiveRecord::Base.transaction do
        # Retain the original name if the user already exists
        user.update!(full_name:) unless user.participant_profiles&.active_record&.any? || user.npq_registered?

        create_teacher_profile

        raise ParticipantProfileExistsError if participant_profile_exists?

        profile = ParticipantProfile::ECT.create!(
          teacher_profile:,
          schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort.cohort),
          participant_identity: Identity::Create.call(user:),
          **ect_attributes,
        )

        ParticipantProfileState.create!(participant_profile: profile, cpd_lead_provider: induction_programme&.lead_provider&.cpd_lead_provider)
        if induction_programme.present?
          Induction::Enrol.call(participant_profile: profile,
                                induction_programme:,
                                mentor_profile:,
                                start_date:,
                                appropriate_body_id:)
        end
      end

      profile
    end

  private

    attr_reader :full_name, :email, :induction_programme, :school_cohort, :mentor_profile_id, :start_date, :appropriate_body_id, :induction_start_date

    def initialize(full_name:, email:, school_cohort:, mentor_profile_id: nil, start_date: nil, appropriate_body_id: nil, induction_start_date: nil)
      @full_name = full_name
      @email = email
      @school_cohort = school_cohort
      @mentor_profile_id = mentor_profile_id
      @start_date = start_date
      @appropriate_body_id = appropriate_body_id
      @induction_start_date = induction_start_date
      @induction_programme = induction_programme || school_cohort.default_induction_programme
    end

    def ect_attributes
      {
        school_cohort_id: school_cohort.id,
        mentor_profile_id:,
        sparsity_uplift: sparsity_uplift?(start_year),
        pupil_premium_uplift: pupil_premium_uplift?(start_year),
        induction_start_date:,
      }
    end

    def teacher_profile
      @teacher_profile ||= TeacherProfile.find_or_create_by!(user:) do |teacher|
        teacher.school = school_cohort.school
      end
    end
    alias_method :create_teacher_profile, :teacher_profile

    def user
      @user ||= User.find_or_create_by!(email:) do |ect|
        ect.full_name = full_name
      end
    end

    def mentor_profile
      ParticipantProfile::Mentor.find(mentor_profile_id) if mentor_profile_id.present?
    end

    def participant_profile_exists?
      teacher_profile.participant_profiles.ects.exists? || user.participant_identities.joins(:participant_profiles).where(participant_profiles: { type: "ParticipantProfile::ECT" }).exists?
    end
  end
end
