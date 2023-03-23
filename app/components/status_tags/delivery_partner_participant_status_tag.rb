# frozen_string_literal: true

module StatusTags
  class DeliveryPartnerParticipantStatusTag < BaseComponent
    def initialize(participant_profile:, induction_record: nil)
      @participant_profile = participant_profile
      @induction_record = induction_record
    end

    def call
      title = t(:title, scope: translation_scope)
      description = t(:description, scope: translation_scope)

      if description.present?
        content_tag(:strong, title) +
          content_tag(:p, description, class: "govuk-body-s")
      else
        content_tag(:strong, title)
      end
    end

  private

    attr_reader :participant_profile, :induction_record

    def translation_scope
      @translation_scope ||= "participant_profile_status.status.#{record_state}"
    end

    def record_state
      @record_state ||= ParticipantProfileStatus.new(
        participant_profile:,
        induction_record:,
      ).status_name
    end
  end
end
