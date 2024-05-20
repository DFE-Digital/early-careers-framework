# frozen_string_literal: true

# Change the current cohort of an ECF participant.
# In doing so it will add an IR with an induction_programme and schedule on the new cohort.
# Also, the participant profile will get their cohort and schedule updated.
#
# The induction_programme will be the default one for the new cohort in the current school.
# The schedule will be the provided one or the equivalent to the current but in destination cohort with start year :target_cohort_start_year
#
# Several validations are run before allowing the change. Specially important are existing declarations.
#
# Examples:
#  - This will set induction_programme and schedule for the participant_profile to 2022/23 cohort
#      checking they are sitting currently in 2021/2022
#       Induction::AmendParticipantCohort.new(participant_profile:,
#                                             source_cohort_start_year: 2021,
#                                             target_cohort_start_year: 2022,
#                                             reason_for_new_cohort: :registration_mistake).save
#
#  - This will set induction_programme and schedule for the participant_profile
#    to the cohort of :schedule checking they sits currently in 2021/2022
#       Induction::AmendParticipantCohort.new(participant_profile:,
#                                             source_cohort_start_year: 2021,
#                                             schedule:,
#                                             reason_for_new_cohort: :lead_provider_change).save
#
#  - For cohort changes on participants whose current cohort has been payments_closed pass
#    reason_for_new_cohort: :payments_frozen_at_previous_cohort
#    This will allow the cohort change to complete successfully even if the participant has billable declarations.
#
module Induction
  class AmendParticipantCohort
    include ActiveModel::Model

    ECF_FIRST_YEAR = 2020

    attr_accessor :participant_profile, :source_cohort_start_year, :target_cohort_start_year,
                  :reason_for_new_cohort
    attr_writer :schedule

    validates :source_cohort_start_year,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: ECF_FIRST_YEAR,
                less_than_or_equal_to: Date.current.year,
                message: :invalid,
                start: ECF_FIRST_YEAR,
                end: Date.current.year,
              },
              on: :start

    validate :reason_matches_source_cohort_frozen,
             on: :start

    validates :target_cohort_start_year,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: ECF_FIRST_YEAR,
                less_than_or_equal_to: Date.current.year,
                message: :invalid,
                start: ECF_FIRST_YEAR,
                end: Date.current.year,
              },
              on: :start

    validates :target_cohort,
              presence: {
                message: ->(form, _) { I18n.t("errors.cohort.blank", year: form.target_cohort_start_year, where: "the service") },
              },
              on: :start

    validates :participant_profile,
              presence: true,
              on: :start

    validate :target_cohort_start_year_matches_schedule

    validates :participant_profile,
              active_participant_profile: true,
              unfinished_training_participant_profile: true

    validates :participant_declarations,
              absence: { message: :billable_or_submitted }

    validates :induction_record,
              presence: {
                message: ->(form, _) { I18n.t("errors.induction_record.blank", year: form.source_cohort_start_year) },
              }

    validates :target_school_cohort,
              presence: {
                message: ->(form, _) { I18n.t("errors.cohort.blank", year: form.target_cohort_start_year, where: form.school&.name) },
              }

    validates :induction_programme,
              presence: {
                message: ->(form, _) { I18n.t("errors.induction_programme.blank", year: form.target_cohort_start_year, school: form.school&.name) },
              }

    delegate :school, to: :induction_record, allow_nil: true

    def save
      return false unless valid?(:start)
      return true if in_target?(induction_record)

      valid? && current_induction_record_updated?
    end

  private

    def initialize(*)
      super
      @target_cohort_start_year = (@target_cohort_start_year || @schedule&.cohort_start_year).to_i
      @reason_for_new_cohort ||= :unknown
    end

    def current_induction_record_updated?
      ActiveRecord::Base.transaction do
        Induction::ChangeInductionRecord.call(induction_record:,
                                              changes: { induction_programme:,
                                                         schedule:,
                                                         training_status: :active })
        participant_profile.update!(school_cohort: target_school_cohort,
                                    schedule:,
                                    training_status: :active,
                                    previous_cohort: source_cohort,
                                    reason_for_new_cohort:)
      rescue ActiveRecord::RecordInvalid => e
        errors.add(:induction_record, induction_record.errors.full_messages.first) if induction_record.errors.any?
        errors.add(:participant_profile, participant_profile.errors.full_messages.first) if participant_profile.errors.any?
        errors.add(:induction_record, e.message) if errors.empty?
        false
      end
    end

    def induction_programme
      @induction_programme ||= if induction_record && in_target_cohort?(induction_record)
                                 induction_record.induction_programme
                               else
                                 target_school_cohort&.default_induction_programme
                               end
    end

    def induction_record
      return unless participant_profile

      @induction_record ||= participant_profile.induction_records
                                               .active_induction_status
                                               .joins(induction_programme: { school_cohort: :cohort })
                                               .where(cohorts: { start_year: source_cohort_start_year })
                                               .latest
    end

    def in_target?(induction_record)
      in_target_cohort?(induction_record) && in_target_schedule?(induction_record)
    end

    def in_target_cohort?(induction_record)
      induction_record.cohort_start_year == target_cohort_start_year
    end

    def in_target_schedule?(induction_record)
      induction_record.schedule == schedule
    end

    def participant_declarations
      return false unless participant_profile
      return @participant_declarations if instance_variable_defined?(:@participant_declarations)

      @participant_declarations = if payments_frozen?
                                    participant_profile
                                      .participant_declarations
                                      .for_declaration("completed")
                                      .billable
                                      .exists?
                                  else
                                    participant_profile
                                      .participant_declarations
                                      .billable_or_changeable
                                      .exists?
                                  end
    end

    def payments_frozen?
      reason_for_new_cohort == :payments_frozen_at_previous_cohort && source_cohort&.payments_frozen?
    end

    def schedule
      @schedule ||= if induction_record && in_target_cohort?(induction_record)
                      induction_record.schedule
                    else
                      Finance::Schedule::ECF.find_by(cohort: target_cohort,
                                                     schedule_identifier: induction_record&.schedule_identifier) ||
                        Finance::Schedule::ECF.default_for(cohort: target_cohort)
                    end
    end

    def source_cohort
      @source_cohort ||= Cohort.find_by(start_year: source_cohort_start_year)
    end

    def target_cohort
      @target_cohort ||= Cohort.find_by(start_year: target_cohort_start_year)
    end

    def target_school_cohort
      @target_school_cohort ||= SchoolCohort.find_by(school:, cohort: target_cohort)
    end

    # Validations
    def reason_matches_source_cohort_frozen
      if reason_for_new_cohort == :payments_frozen_at_previous_cohort && !source_cohort&.payments_frozen?
        errors.add(:reason_for_new_cohort, :payments_not_frozen_at_source_cohort)
      end
    end

    def target_cohort_start_year_matches_schedule
      if schedule && target_cohort_start_year != schedule.cohort_start_year
        errors.add(:target_cohort_start_year, :incompatible_with_schedule)
      end
    end
  end
end
