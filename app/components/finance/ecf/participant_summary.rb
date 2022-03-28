# frozen_string_literal: true

module Finance
  module ECF
    class ParticipantSummary < BaseComponent
      include ECFPaymentsHelper
      attr_reader :breakdown_started_summary, :breakdown_retained_1_summary

      def initialize(breakdown_started_summary:, breakdown_retained_1_summary:)
        @breakdown_started_summary = breakdown_started_summary
        @breakdown_retained_1_summary = breakdown_retained_1_summary
      end

      def breakdown_started_participants
        breakdown_started_summary[:participants]
      end

      def breakdown_retained_participants
        breakdown_retained_1_summary[:participants]
      end

      def breakdown_started_summary_not_yet_included
        breakdown_started_summary[:not_yet_included_participants]
      end

      def breakdown_retained_summary_not_yet_included
        breakdown_retained_1_summary[:not_yet_included_participants]
      end
    end
  end
end
