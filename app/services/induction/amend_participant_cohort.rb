# frozen_string_literal: true

# Change the cohort of an ECF participant.
# In doing so it will add an IR with an induction_programme and schedule on the new cohort.
# Also, the participant profile will get their cohort and schedule updated.
#
# The induction_programme will be the default one for the new cohort in the current school.
# The schedule will be the provided one or the equivalent to the current one in the cohort with start year :target_cohort_start_year
#
# Several validations are run before allowing the change. Specially important are existing declarations.
#
# Examples:
#  - This will set induction_programme and schedule for the participant_profile to 2022/23 cohort
#      checking they are sitting currently in 2021/2022
#       Induction::AmendParticipantCohort.new(participant_profile:,
#                                             source_cohort_start_year: 2021,
#                                             target_cohort_start_year: 2022).save
#
#  - This will set induction_programme and schedule for the participant_profile
#    to the cohort of :schedule checking they sits currently in 2021/2022
#       Induction::AmendParticipantCohort.new(participant_profile:,
#                                             source_cohort_start_year: 2021,
#                                             schedule:).save
#
#  - For cohort changes on participants whose current cohort has been payments_frozen and are transferred to
#    the active registration cohort, it will automatically flag the participant_profile as
#    cohort_changed_after_payments_frozen: true
#
module Induction
  class AmendParticipantCohort
    include ActiveModel::Model

    ECF_FIRST_YEAR = 2020

    attr_accessor :participant_profile, :source_cohort_start_year, :target_cohort_start_year
    attr_writer :schedule

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

    validate :target_cohort_start_year_matches_schedule
    validate :participant_with_no_notes
    validate :transfer_from_payments_frozen_cohort, if: :transfer_from_payments_frozen_cohort?
    validate :transfer_to_payments_frozen_cohort, if: :back_to_payments_frozen_cohort?

    validates :participant_declarations,
              absence: { message: :billable_or_submitted },
              unless: :payments_frozen_transfer?

    validates :induction_record,
              presence: {
                message: ->(form, _) { I18n.t("errors.induction_record.blank", year: form.source_cohort_start_year) },
              }

    validate :niot_exception

    validates :target_school_cohort,
              presence: {
                message: ->(form, _) { I18n.t("errors.cohort.not_setup", year: form.target_cohort_start_year, where: form.school&.name) },
              }

    validates :induction_programme,
              presence: {
                message: ->(form, _) { I18n.t("errors.induction_programme.not_setup", year: form.target_cohort_start_year, school: form.school&.name) },
              }

    delegate :school, to: :induction_record, allow_nil: true

    def save
      return false unless valid?
      return true if in_target?(induction_record)

      current_induction_record_updated?
    end

  private

    def initialize(*)
      super
      @target_cohort_start_year = (@target_cohort_start_year || @schedule&.cohort_start_year).to_i
    end

    def back_to_payments_frozen_cohort?
      participant_profile&.cohort_changed_after_payments_frozen? && target_cohort&.payments_frozen?
    end

    def billable_declarations_in_cohort?(cohort)
      participant_profile.participant_declarations.where(cohort:).billable.exists?
    end

    def current_induction_record_updated?
      ActiveRecord::Base.transaction do
        Induction::ChangeInductionRecord.call(induction_record:,
                                              changes: { induction_programme:,
                                                         schedule: })
        participant_profile.update!(school_cohort: target_school_cohort,
                                    schedule:,
                                    cohort_changed_after_payments_frozen:)
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
                                               .where.not(induction_status: :changed)
                                               .joins(induction_programme: { school_cohort: :cohort })
                                               .where(cohorts: { start_year: source_cohort_start_year })
                                               .latest
    end

    def in_target?(induction_record)
      induction_record && in_target_cohort?(induction_record) && in_target_schedule?(induction_record)
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

      @participant_declarations = participant_profile
                                    .participant_declarations
                                    .billable_or_changeable
                                    .exists?
    end

    def schedule
      @schedule ||= Induction::ScheduleForNewCohort.call(cohort: target_cohort,
                                                         induction_record:,
                                                         cohort_changed_after_payments_frozen:)
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

    def payments_frozen_transfer?
      transfer_from_payments_frozen_cohort? || back_to_payments_frozen_cohort?
    end

    def transfer_from_payments_frozen_cohort?
      source_cohort&.payments_frozen? && target_cohort == Cohort.active_registration_cohort
    end

    alias_method :cohort_changed_after_payments_frozen, :transfer_from_payments_frozen_cohort?

    # Validations

    def niot
      @niot ||= Niot.lead_provider
    end

    def niot_exception
      errors.add(:induction_record, :niot_participant) if niot_forbidden_target_cohort?
    end

    def niot_first_training_year
      @niot_first_training_year ||= Niot.first_training_year
    end

    def niot_forbidden_target_cohort?
      return false unless niot_participant?
      return false unless niot_first_training_year

      target_cohort_start_year < niot_first_training_year
    end

    def niot_participant?
      return false unless niot
      return false unless induction_record

      induction_record.lead_provider_id == niot.id
    end

    def participant_with_no_notes
      errors.add(:participant_profile, :with_notes) if participant_profile&.notes.present?
    end

    def transfer_from_payments_frozen_cohort
      unless participant_profile.eligible_to_change_cohort_and_continue_training?(cohort: target_cohort)
        errors.add(:participant_profile, :not_eligible_to_be_transferred_from_current_cohort)
      end
    end

    def transfer_to_payments_frozen_cohort
      unless participant_profile.eligible_to_change_cohort_back_to_their_payments_frozen_original?(cohort: target_cohort, current_cohort: source_cohort)
        errors.add(:participant_profile, :billable_declarations_in_cohort) if billable_declarations_in_cohort?(source_cohort)
        errors.add(:participant_profile, :no_billable_declarations_in_cohort) unless billable_declarations_in_cohort?(target_cohort)
        errors.add(:participant_profile, :not_eligible_to_be_transferred_back)
      end
    end

    def target_cohort_start_year_matches_schedule
      if schedule && target_cohort_start_year != schedule.cohort_start_year
        errors.add(:target_cohort_start_year, :incompatible_with_schedule)
      end
    end
  end
end
