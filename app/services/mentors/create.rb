# frozen_string_literal: true

module Mentors
  class Create < BaseService
    include SchoolCohortDelegator
    ParticipantProfileExistsError = Class.new(RuntimeError)

    def call
      mentor_profile = nil
      ActiveRecord::Base.transaction do
        user.update!(full_name:) unless user.teacher_profile&.participant_profiles&.active_record&.any?

        create_teacher_profile

        raise ParticipantProfileExistsError if participant_profile_exists?

        mentor_profile = ParticipantProfile::Mentor.create!({
          teacher_profile:,
          schedule: Finance::Schedule::ECF.default_for(cohort: school_cohort.cohort),
          participant_identity: Identity::Create.call(user:, email:),
        }.merge(mentor_attributes))

        ParticipantProfileState.create!(participant_profile: mentor_profile, cpd_lead_provider: school_cohort&.default_induction_programme&.lead_provider&.cpd_lead_provider)

        if school_cohort.default_induction_programme.present?
          Induction::Enrol.call(participant_profile: mentor_profile,
                                induction_programme: school_cohort.default_induction_programme,
                                start_date:)
        end

        Mentors::AddToSchool.call(school: school_cohort.school, mentor_profile:)
      end

      unless sit_validation
        ParticipantMailer.participant_added(participant_profile: mentor_profile).deliver_later
        mentor_profile.update_column(:request_for_details_sent_at, Time.zone.now)
        ParticipantDetailsReminderJob.schedule(mentor_profile)
      end

      mentor_profile
    end

  private

    attr_reader :full_name, :email, :school_cohort, :start_date, :sit_validation

    def initialize(full_name:, email:, school_cohort:, start_date: nil, sit_validation: false, **)
      @full_name = full_name
      @email = email
      @start_date = start_date
      @school_cohort = school_cohort
      @sit_validation = sit_validation
    end

    def mentor_attributes
      {
        school_cohort_id: school_cohort.id,
        sparsity_uplift: sparsity_uplift?(start_year),
        pupil_premium_uplift: pupil_premium_uplift?(start_year),
      }
    end

    def user
      # NOTE: This will not update the full_name if the user has an active participant profile,
      # the scenario I am working on is enabling a NPQ user to be added as a mentor
      # Not matching on full_name means this works more smoothly for the end user
      # and they don't get "email already in use" errors if they spell the name differently
      @user ||= find_or_create_user!
    end

    def find_or_create_user!
      Identity.find_user_by(email:) || User.create!(email:, full_name:)
    end

    def teacher_profile
      @teacher_profile ||= TeacherProfile.find_or_create_by!(user:) do |profile|
        profile.school = school_cohort.school
      end
    end
    alias_method :create_teacher_profile, :teacher_profile

    def participant_profile_exists?
      teacher_profile.participant_profiles.mentors.exists? || user.participant_identities.joins(:participant_profiles).where(participant_profiles: { type: "ParticipantProfile::Mentor" }).exists?
    end
  end
end
