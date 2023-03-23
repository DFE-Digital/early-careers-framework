# frozen_string_literal: true

module Schools
  module Participants
    class Status < BaseComponent
      def initialize(participant_profile:)
        @participant_profile = participant_profile
        @induction_record = nil
      end

    private

      attr_reader :participant_profile, :induction_record

      def heading
        t :header, scope: translation_scope
      end

      def content
        Array.wrap(t(:content, scope: translation_scope, contact_us: render(MailToSupportComponent.new("contact us")))).map(&:html_safe)
      end

      def translation_scope
        @translation_scope ||= "schools.participants.status.#{record_state}"
      end

      def record_state
        @record_state ||= SchoolParticipantsStatusTagStatus.new(
          participant_profile:,
          induction_record:,
        ).record_state
      end
    end
  end
end
