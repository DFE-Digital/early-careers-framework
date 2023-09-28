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

        profile = find_or_create_participant_profile

        ParticipantProfileState.create!(participant_profile: profile,
                                        cpd_lead_provider: school_cohort&.default_induction_programme&.lead_provider&.cpd_lead_provider)

        if school_cohort.default_induction_programme.present?
          Induction::Enrol.call(participant_profile: profile,
                                induction_programme: school_cohort.default_induction_programme,
                                mentor_profile:,
                                start_date:,
                                appropriate_body_id:)
        end
      end

      profile
    end

  private

    attr_reader :full_name, :email, :school_cohort, :mentor_profile_id, :start_date, :appropriate_body_id, :induction_start_date

    def initialize(full_name:, email:, school_cohort:, mentor_profile_id: nil, start_date: nil, appropriate_body_id: nil, induction_start_date: nil)
      @full_name = full_name
      @email = email
      @school_cohort = school_cohort
      @mentor_profile_id = mentor_profile_id
      @start_date = start_date
      @appropriate_body_id = appropriate_body_id
      @induction_start_date = induction_start_date
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
      @teacher_profile ||= TeacherProfile.find_or_create_by!(user:).tap do |teacher_profile|
        teacher_profile.update!(school: school_cohort.school)
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

    def school
      school_cohort.school
    end

    def find_or_create_participant_profile
      if existing_participant_profile.present?
        existing_participant_profile.update!(
          teacher_profile:,
          schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort.cohort),
          **ect_attributes,
        )
        existing_participant_profile
      else
        ParticipantProfile::ECT.create!(
          teacher_profile:,
          schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort.cohort),
          participant_identity: Identity::Create.call(user:),
          **ect_attributes,
        )
      end
    end

    def existing_participant_profile
      via_teacher_profile = teacher_profile.participant_profiles.ects.first
      return via_teacher_profile if via_teacher_profile.present?

      participant_identity = ParticipantIdentityResolver.call(
        participant_id: user.id,
        course_identifier: "ecf-induction",
        cpd_lead_provider: nil,
      )
      ParticipantProfileResolver.call(
        participant_identity:,
        course_identifier: "ecf-induction",
        cpd_lead_provider: nil,
      )
    end
  end
end
