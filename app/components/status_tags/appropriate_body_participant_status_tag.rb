# frozen_string_literal: true

module StatusTags
  class AppropriateBodyParticipantStatusTag < BaseComponent
    def initialize(participant_profile:, induction_record: nil, delivery_partner: nil, school: nil)
      if school.present? && delivery_partner.present?
        raise InvalidArgumentError "It is not possible to determine a status for both a school and a delivery partner"
      end

      @participant_profile = participant_profile

      if delivery_partner.present?
        @delivery_partner = delivery_partner
        @induction_record = Induction::FindBy.call(participant_profile:, delivery_partner:)

      elsif school.present?
        @school = school
        @induction_record = Induction::FindBy.call(participant_profile:, delivery_partner:)

      else
        @induction_record = induction_record || participant_profile.induction_records.latest
      end
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

    attr_reader :participant_profile, :induction_record

    def translation_scope
      @translation_scope ||= "status_tags.appropriate_body_participant_status.#{record_state}"
    end

    def record_state
      @record_state ||= ParticipantProfileStatus.new(
        participant_profile:,
        induction_record:,
      ).record_state
    end
  end
end
