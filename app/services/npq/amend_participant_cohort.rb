# frozen_string_literal: true

module NPQ
  class AmendParticipantCohort
    include ActiveModel::Validations

    attr_accessor :npq_application_id, :target_cohort_start_year

    validates :npq_application_id, :target_cohort_start_year, presence: true
    validates :npq_application,
              presence: { message: I18n.t("errors.npq_application.blank") }
    validates :target_cohort,
              presence: {
                message: lambda do |form, _|
                  I18n.t("errors.cohort.blank", year: form.target_cohort_start_year, where: "the service")
                end,
              }
    validate :participant_profile_has_no_declarations
    validate :source_cohort_different_to_target_cohort

    def initialize(npq_application_id:, target_cohort_start_year:)
      @npq_application_id = npq_application_id
      @target_cohort_start_year = target_cohort_start_year
    end

    def call
      return if invalid?

      ActiveRecord::Base.transaction do
        npq_application.update!(cohort: target_cohort)
        participant_profile.update!(schedule: target_schedule) if participant_profile
      end
    end

  private

    def source_cohort
      @source_cohort ||= npq_application.cohort
    end

    def target_cohort
      @target_cohort ||= Cohort[target_cohort_start_year]
    end

    def npq_application
      @npq_application ||= NPQApplication.find_by(id: npq_application_id)
    end

    def participant_profile
      @participant_profile ||= npq_application&.profile
    end

    def participant_declarations
      @participant_declarations ||= participant_profile.participant_declarations
    end

    def source_schedule
      @source_schedule ||= participant_profile.schedule
    end

    def target_schedule
      Finance::Schedule::NPQ.find_by(cohort: target_cohort, name: source_schedule.name, schedule_identifier: source_schedule.schedule_identifier, type: source_schedule.type)
    end

    def source_cohort_different_to_target_cohort
      return unless npq_application

      if npq_application.cohort == target_cohort
        errors.add(:target_cohort_start_year, I18n.t("errors.cohort.excluded_start_year", year: source_cohort.start_year))
      end
    end

    def participant_profile_has_no_declarations
      return unless participant_profile

      if participant_declarations.any?
        errors.add(:base, I18n.t("errors.participant_declarations.exist"))
      end
    end
  end
end
