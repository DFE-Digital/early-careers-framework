# frozen_string_literal: true

module Dashboard
  class Participants
    class Filter
      class Option
        attr_reader :id

        def initialize(id:, dashboard_participants:)
          @id = id
          @dashboard_participants = dashboard_participants
        end

        def label
          count_method_name = "#{id}_count"
          "#{id.to_s.capitalize.humanize} (#{@dashboard_participants.send(count_method_name)})"
        end
      end
    end
  end
end
