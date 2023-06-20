# frozen_string_literal: true

module StatusTags
  class DeliveryPartnerParticipantStatusTag < BaseComponent
    def initialize(participant_profile:, delivery_partner: nil, display_description: true)
      @participant_profile = participant_profile
      @display_description = display_description
      @delivery_partner = delivery_partner
    end

    def label
      t :label, scope: translation_scope
    end

    def id
      t :id, scope: translation_scope
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

    attr_reader :participant_profile, :delivery_partner, :display_description

    def translation_scope
      @translation_scope ||= "status_tags.delivery_partner_participant_status.#{record_state}"
    end

    def record_state
      @record_state ||= DetermineTrainingRecordState.call(participant_profile:, delivery_partner:)&.record_state || :no_longer_involved
    end
  end
end
