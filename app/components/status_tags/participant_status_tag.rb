# frozen_string_literal: true

module StatusTags
  class ParticipantStatusTag < BaseComponent
    def initialize(participant_profile:, induction_record: nil)
      @participant_profile = participant_profile
      @induction_record = induction_record
    end

  private

    attr_reader :participant_profile, :induction_record

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

    def translation_scope
      @translation_scope ||= "status_tags.participant_status.#{record_state}"
    end

    def record_state
      @record_state ||= ParticipantStatusTagStatus.new(
        participant_profile:,
        induction_record:,
      ).record_state
    end
  end
end
