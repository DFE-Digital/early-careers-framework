# frozen_string_literal: true

module StatusTags
  class SchoolParticipantStatusTag < BaseComponent
    def initialize(participant_profile:,
                   induction_record: nil,
                   school: nil,
                   display_description: true,
                   display_induction_start_date: false)
      @participant_profile = participant_profile
      @induction_record = induction_record
      @display_description = display_description
      @display_induction_start_date = display_induction_start_date
      @school = school
    end

    def label
      t :label, scope: translation_scope
    end

    def description
      Array.wrap(t(:description, scope: translation_scope, contact_us:, appropriate_body_name:, induction_completion_date:)).map(&:html_safe)
    rescue I18n::MissingTranslationData
      []
    end

    def colour
      t :colour, scope: translation_scope
    end

    delegate :induction_start_date, to: :participant_profile

  private

    attr_reader :participant_profile, :induction_record, :school, :display_description, :display_induction_start_date

    def translation_scope
      @translation_scope ||= "status_tags.school_participant_status.#{record_state}"
    end

    def record_state
      @record_state ||= DetermineTrainingRecordStateLegacy.call(participant_profile:, induction_record:, school:)&.record_state || :no_longer_involved
    end

    def appropriate_body_name
      @induction_record&.appropriate_body_name || "Your appropriate body"
    end

    def induction_completion_date
      @participant_profile&.induction_completion_date&.to_fs(:govuk)
    end

    def contact_us
      render(MailToSupportComponent.new("contact us"))
    end
  end
end
