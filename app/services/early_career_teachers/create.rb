# frozen_string_literal: true

module EarlyCareerTeachers
  class Create < BaseService
    include SchoolCohortDelegator

    def call
      profile = nil
      ActiveRecord::Base.transaction do
        # Retain the original name if the user already exists
        user = User.find_or_create_by!(email: email) do |ect|
          ect.full_name = full_name
        end
        user.update!(full_name: full_name) unless user.participant_profiles&.active_record&.any? || user.npq_registered?

        teacher_profile = TeacherProfile.find_or_create_by!(user: user) do |teacher|
          teacher.school = school_cohort.school
        end

        self.profile = ParticipantProfile::ECT.create!({
          teacher_profile: teacher_profile,
          schedule: Finance::Schedule::ECF.default,
          participant_identity: Identity::Create.call(user: user),
        }.merge(ect_attributes))
        profile.participant_profile_states.create!
      end

      send_participant_added_mailer(profile) unless year_2020
        ParticipantProfileState.create!(participant_profile: profile)
        Induction::Enrol.call(participant_profile: profile) if school_cohort.default_induction_programme.present?
      end

      unless year_2020
        ParticipantMailer.participant_added(participant_profile: profile).deliver_later
        profile.update_column(:request_for_details_sent_at, Time.zone.now)
        ParticipantDetailsReminderJob.schedule(profile)
      end

      profile
    end

  private

    attr_reader :full_name, :email, :start_term, :school_cohort, :mentor_profile_id, :year_2020
    attr_accessor :profile

    def initialize(full_name:, email:, school_cohort:, mentor_profile_id: nil, start_term: "autumn_2021", year_2020: false)
      @full_name = full_name
      @email = email
      @start_term = start_term
      @school_cohort = school_cohort
      @mentor_profile_id = mentor_profile_id
      @year_2020 = year_2020
    end

    def ect_attributes
      {
        start_term: start_term,
        school_cohort_id: school_cohort.id,
        mentor_profile_id: mentor_profile_id,
        sparsity_uplift: sparsity_uplift?(start_year),
        pupil_premium_uplift: pupil_premium_uplift?(start_year),
      }
    end

    def send_participant_added_mailer(profile)
      ActiveRecord::Base.transaction do
        ParticipantMailer.participant_added(participant_profile: profile).deliver_later
        profile.update_column(:request_for_details_sent_at, Time.zone.now)
        ParticipantDetailsReminderJob.schedule(profile)
      end
    end
  end
end
