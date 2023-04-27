# frozen_string_literal: true

module Induction
  class AmendParticipantCohort
    include ActiveModel::Model

    class ActiveValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, I18n.t("errors.participant_profile.not_active")) unless active?(value)
      end

      def active?(participant_profile)
        participant_profile&.active_record? && participant_profile&.training_status_active?
      end
    end

    ECF_FIRST_YEAR = 2020

    attr_accessor :participant_profile, :source_cohort_start_year, :target_cohort_start_year

    validates :source_cohort_start_year,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: ECF_FIRST_YEAR,
                less_than_or_equal_to: Date.current.year,
                message: :invalid,
                start: ECF_FIRST_YEAR,
                end: Date.current.year,
              }
    validates :target_cohort_start_year,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: ECF_FIRST_YEAR,
                less_than_or_equal_to: Date.current.year,
                message: :invalid,
                start: ECF_FIRST_YEAR,
                end: Date.current.year,
              }
    validates :target_cohort,
              presence: {
                message: ->(form, _) { I18n.t("errors.cohort.blank", year: form.target_cohort_start_year, where: "the service") },
              }
    validates :participant_profile,
              presence: true,
              participant_profile_active: true
    validates :participant_declarations, absence: { message: :billable_or_submitted }
    validates :induction_record,
              presence: {
                message: ->(form, _) { I18n.t("errors.induction_record.blank", year: form.source_cohort_start_year) },
              }
    validates :target_school_cohort,
              presence: {
                message: ->(form, _) { I18n.t("errors.cohort.blank", year: form.target_cohort_start_year, where: form.school&.name) },
              }

    delegate :school, to: :induction_record, allow_nil: true

    def save
      valid? && current_induction_record_changed? && historical_records_changed?
    end

  private

    def current_induction_record_changed?
      return true if in_target_cohort?(induction_record)

      ActiveRecord::Base.transaction do
        induction_record.update!(induction_programme:, start_date:, schedule:)
        participant_profile.update!(school_cohort: target_school_cohort, schedule:)
      rescue ActiveRecord::RecordInvalid
        errors.add(:induction_record, induction_record.errors.full_messages.first) if induction_record.errors.any?
        errors.add(:participant_profile, participant_profile.errors.full_messages.first) if participant_profile.errors.any?
        false
      end
    end

    def historical_records_changed?
      historical_records.all? do |historical_record|
        next true if in_target_cohort?(historical_record)

        begin
          historical_record.update!(induction_programme: historical_default_induction_programme(historical_record),
                                    start_date:,
                                    schedule:)
        rescue ActiveRecord::RecordInvalid
          false
        end
      end
    end

    def historical_records
      return [] unless participant_profile

      @historical_records ||= participant_profile.induction_records.order(created_at: :desc)
    end

    def historical_default_induction_programme(historical_record)
      historical_target_school_cohort(historical_record.school).default_induction_programme.tap do |induction_programme|
        if induction_programme.nil?
          errors.add(:historical_records,
                     :no_default_induction_programme,
                     start_academic_year: target_cohort_start_year,
                     school_name: historical_record.school.name)
          raise ActiveRecord::RecordInvalid
        end
      end
    end

    def historical_target_school_cohort(school)
      school.school_cohorts.for_year(target_cohort_start_year).first.tap do |school_cohort|
        if school_cohort.nil?
          errors.add(:historical_records,
                     :school_cohort_not_setup,
                     start_academic_year: target_cohort_start_year,
                     school_name: school.name)
          raise ActiveRecord::RecordInvalid
        end
      end
    end

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

    def in_target_cohort?(induction_record)
      induction_record.cohort_start_year == target_cohort_start_year.to_i
    end

    def participant_declarations
      return false unless participant_profile

      @participant_declarations ||= participant_profile
                                      .participant_declarations
                                      .billable_or_changeable
                                      .declared_as_between(source_cohort_start_date, source_cohort_end_date)
                                      .exists?
    end

    def schedule
      @schedule ||= Finance::Schedule::ECF.default_for(cohort: target_cohort)
    end

    def source_cohort
      @source_cohort ||= Cohort.find_by(start_year: source_cohort_start_year)
    end

    def source_cohort_start_date
      @source_cohort_start_date ||= source_cohort.academic_year_start_date
    end

    def source_cohort_end_date
      @source_cohort_end_date ||= source_cohort_start_date + 1.year - 1.day
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
