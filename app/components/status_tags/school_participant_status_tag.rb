# frozen_string_literal: true

module StatusTags
  class SchoolParticipantStatusTag < BaseComponent
    def initialize(participant_profile:, induction_record: nil, school: nil)
      @participant_profile = participant_profile
      @school = school
      @induction_record = induction_record
    end

    def label
      t :label, scope: translation_scope
    end

    def description
      Array.wrap(t(:description, scope: translation_scope, contact_us: render(MailToSupportComponent.new("contact us")))).map(&:html_safe)
    rescue I18n::MissingTranslationData
      []
    end

    def colour
      t :colour, scope: translation_scope
    end

  private

    attr_reader :participant_profile, :induction_record, :school

    def translation_scope
      @translation_scope ||= if FeatureFlag.active?(:school_participant_status_language)
                               "status_tags.school_participant_status_detailed.#{record_state}"
                             else
                               "status_tags.school_participant_status.#{record_state}"
                             end
    end

    def record_state
      @record_state ||= determine_record_state
    end

    def determine_record_state
      record_state = DetermineTrainingRecordState.call(
        participant_profile:,
        induction_record:,
        school:,
      ).record_state

      # Schools logic states that we show eligible for CIP participants whether that is correct or not
      if on_cip? && is_ignored_for_cip?(record_state)
        return :active_cip_training
      end

      record_state
    end

    def on_cip?
      @induction_record&.induction_programme&.core_induction_programme? || @participant_profile.school_cohort&.core_induction_programme?
    end

    def is_ignored_for_cip?(record_state)
      %i[
        internal_error
        tra_record_not_found
        active_flags
        different_trn
        checks_not_complete
        no_induction_start
        not_allowed
        duplicate_profile
        exempt_from_induction
        previous_participation
        previous_induction
        not_qualified
        previous_participation_ero
        registered_for_mentor_training
        registered_for_mentor_training_ero
        registered_for_mentor_training_primary
        registered_for_mentor_training_primary_ero
        registered_for_mentor_training_secondary
        registered_for_mentor_training_secondary_ero
        registered_for_mentor_training_duplicate
        registered_for_mentor_training_duplicate_ero
      ].include?(record_state.to_sym)
    end
  end
end
