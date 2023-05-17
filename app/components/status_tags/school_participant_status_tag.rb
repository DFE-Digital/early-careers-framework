# frozen_string_literal: true

module StatusTags
  class SchoolParticipantStatusTag < BaseComponent
    def initialize(participant_profile:, school: nil)
      @participant_profile = participant_profile
      @school = school
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

    attr_reader :participant_profile, :school

    def translation_scope
      @translation_scope ||= "status_tags.school_participant_status.#{record_state}"
    end

    def record_state
      @record_state ||= determine_record_state
    end

    def determine_record_state
      DetermineTrainingRecordState.call(participant_profile:, school:).record_state
    end

    def on_cip?
      @induction_record&.induction_programme&.core_induction_programme? || @participant_profile.school_cohort&.core_induction_programme?
    end
  end
end
