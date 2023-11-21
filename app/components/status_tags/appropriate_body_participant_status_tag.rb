# frozen_string_literal: true

module StatusTags
  class AppropriateBodyParticipantStatusTag < BaseComponent
    attr_reader :training_record_state

    def initialize(training_record_state)
      @training_record_state = training_record_state
    end

    def label
      I18n.t :label, scope: translation_scope
    end

    def id
      I18n.t :id, scope: translation_scope
    end

    def description
      Array.wrap(I18n.t(:description, scope: translation_scope, induction_completion_date:))
    rescue I18n::MissingTranslationData
      []
    end

    def colour
      I18n.t :colour, scope: translation_scope
    end

  private

    def induction_completion_date
      training_record_state.participant_profile.induction_completion_date&.strftime("%-e %B %Y")
    end

    def translation_scope
      @translation_scope ||= "status_tags.appropriate_body_participant_status.#{record_state}"
    end

    def record_state
      @record_state ||= training_record_state&.record_state || :no_longer_involved
    end
  end
end
