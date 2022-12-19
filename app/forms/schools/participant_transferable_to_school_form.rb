# frozen_string_literal: true

module Schools
  class ParticipantTransferableToSchoolForm
    include ActiveModel::Model

    ECF_FIRST_YEAR = 2020

    attr_accessor :participant_profile, :school, :start_year, :skip_school_cohort_validation

    validates :start_year,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: ECF_FIRST_YEAR,
                less_than_or_equal_to: Date.current.year,
                message: I18n.t("errors.cohort.invalid_start_year", start: ECF_FIRST_YEAR, end: Date.current.year),
              }
    validates :cohort,
              presence: {
                message: lambda do |form, _|
                  I18n.t("errors.cohort.blank", year: form.start_year, where: "the service")
                end,
              }
    validates :participant_profile,
              presence: { message: I18n.t("errors.participant_profile.blank") },
              participant_profile_active: true
    validates :participant_declarations, absence: { message: I18n.t("errors.participant_declarations.billable_or_submitted") }
    validates :induction_record, presence: true
    validates :school_cohort,
              presence: {
                unless: :skip_school_cohort_validation,
                message: lambda do |form, _|
                  I18n.t("errors.cohort.blank", year: form.start_year, where: form.school&.name)
                end,
              }

  private

    def induction_record
      return unless participant_profile

      @induction_record ||= participant_profile.induction_records
                                               .active_induction_status
                                               .training_status_active
                                               .latest
    end

    def participant_declarations
      return false unless participant_profile

      @participant_declarations ||= participant_profile
                                      .participant_declarations
                                      .billable_or_changeable
                                      .not_declared_as_between(cohort_start_date, cohort_end_date)
                                      .exists?
    end

    def cohort
      @cohort ||= Cohort[start_year]
    end

    def cohort_start_date
      @cohort_start_date ||= cohort.academic_year_start_date
    end

    def cohort_end_date
      @cohort_end_date ||= cohort_start_date + 1.year - 1.day
    end

    def school_cohort
      @school_cohort ||= SchoolCohort.find_by(school:, cohort:)
    end
  end
end
