# frozen_string_literal: true

module Dashboard
  class Participants
    class Filter
      include ActiveModel::Model

      attr_accessor :dashboard_participants, :filtered_by, :options

      ECT_FILTER_OPTIONS = %w[
        currently_training
        completed_induction
        no_longer_training
      ].freeze

      MENTOR_FILTER_OPTIONS = %w[
        currently_mentoring
        not_mentoring
      ].freeze

      def initialize(*)
        super
        self.filtered_by = default_filter unless filter_option_ids.include?(filtered_by)
      end

      def filter_option_ids
        @filter_option_ids ||= options
      end

      def filter_options
        @filter_options ||= filter_option_ids.map do |id|
          Dashboard::Participants::Filter::Option.new(id:, dashboard_participants:)
        end
      end

    private

      def default_filter
        first_populated_participant_collection || filter_option_ids.first
      end

      def first_populated_participant_collection
        filter_option_ids.select { |filter_option|
          dashboard_participants.send("#{filter_option}_count").positive?
        }.first
      end
    end
  end
end
