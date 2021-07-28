# frozen_string_literal: true

module RecordDeclarations
  class EventFactory
    class << self
      def call(course)
        event_namespace_for_event(course)
      end

    private

      def event_namespace_for_event(course)
        event_identifiers[course.underscore.intern].to_s
      end

      def event_identifiers
        started_identifiers.merge(retained_identifiers)
      end

      def started_identifiers
        %i[started completed].index_with { |_event| "Started" }
      end

      def retained_identifiers
        %i[retained_1 retained_2 retained_3 retained_4].index_with { |_event| "Retained" }
      end
    end
  end
end
