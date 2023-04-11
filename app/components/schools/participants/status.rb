# frozen_string_literal: true

module Schools
  module Participants
    class Status < BaseComponent
      def initialize(induction_record:, has_mentees: false)
        @induction_record = induction_record
        @has_mentees = has_mentees
      end

    private

      attr_reader :induction_record, :has_mentees

      def content
        Array.wrap(t(:content, scope: translation_scope,
                     contact_us: render(MailToSupportComponent.new("contact us")),
                     start_date: induction_record.start_date.to_date.to_s(:govuk),
                     end_date: induction_record.end_date&.to_date&.to_s(:govuk)))
             .map(&:html_safe)
      end

      def heading
        govuk_tag(text: t(:header, scope: translation_scope),
                  colour: t(:colour, scope: translation_scope))
      end

      def profile
        @profile ||= induction_record.participant_profile
      end

      def status
        @status ||= ::Participants::StatusAtSchool.new(induction_record:, has_mentees:, profile:).call
      end

      def translation_scope
        @translation_scope ||= "schools.participants.status.#{status}"
      end
    end
  end
end
