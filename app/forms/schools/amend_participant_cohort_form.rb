# frozen_string_literal: true

module Schools
  class AmendParticipantCohortForm
    include ActiveModel::Model

    ECF_FIRST_YEAR = 2020

    attr_accessor :email, :source_cohort_start_year, :target_cohort_start_year

    validates :email, notify_email: true
    validates :source_cohort_start_year,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: ECF_FIRST_YEAR,
                less_than_or_equal_to: Date.current.year,
                message: I18n.t("errors.cohort.invalid_start_year", start: ECF_FIRST_YEAR, end: Date.current.year),
              }
    validates :target_cohort_start_year,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: ECF_FIRST_YEAR,
                less_than_or_equal_to: Date.current.year,
                message: I18n.t("errors.cohort.invalid_start_year", start: ECF_FIRST_YEAR, end: Date.current.year),
              },
              exclusion: {
                within: ->(form) { [form.source_cohort_start_year] },
                message: ->(form, _) { I18n.t("errors.cohort.excluded_start_year", year: form.source_cohort_start_year) },
              }
    validates :target_cohort,
              presence: {
                message: lambda do |form, _|
                  I18n.t("errors.cohort.blank", year: form.target_cohort_start_year, where: "the service")
                end,
              }
    validates :participant_profile, presence: { message: I18n.t("errors.participant_profile.blank") }
    validates :induction_record,
              presence: {
                message: lambda do |form, _|
                  I18n.t("errors.induction_record.blank", year: form.source_cohort_start_year)
                end,
              }
    validates :target_school_cohort,
              presence: {
                message: lambda do |form, _|
                  I18n.t("errors.cohort.blank", year: form.target_cohort_start_year, where: form.school&.name)
                end,
              }
    delegate :school, to: :induction_record, allow_nil: true

    def save
      valid? && persist
    end

  private

    def induction_programme
      @induction_programme ||= target_school_cohort.default_induction_programme
    end

    def induction_record
      return unless participant_profile

      @induction_record ||= participant_profile.induction_records
                                               .active_induction_status
                                               .training_status_active
                                               .joins(induction_programme: { school_cohort: :cohort })
                                               .where(cohorts: { start_year: source_cohort_start_year })
                                               .latest
    end

    def participant_identity
      @participant_identity ||= ParticipantIdentity.find_by_email(email)
    end

    def participant_profile
      return unless participant_identity

      @participant_profile ||= ParticipantProfile::ECF.training_status_active
                                                      .active_record
                                                      .find_by(participant_identity:)
    end

    def persist
      ActiveRecord::Base.transaction do
        induction_record.update!(induction_programme:, start_date:, schedule:)
        participant_profile.update!(school_cohort: target_school_cohort, schedule:)
      rescue ActiveRecord::RecordInvalid
        false
      end
    end

    def schedule
      @schedule ||= Finance::Schedule::ECF.default_for(cohort: target_cohort)
    end

    def start_date
      @start_date ||= target_cohort.academic_year_start_date
    end

    def target_cohort
      @target_cohort ||= Cohort.find_by(start_year: target_cohort_start_year)
    end

    def target_school_cohort
      @target_school_cohort ||= SchoolCohort.find_by(school:, cohort: target_cohort)
    end
  end
end
