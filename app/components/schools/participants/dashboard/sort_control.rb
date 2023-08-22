# frozen_string_literal: true

module Schools
  module Participants
    module Dashboard
      class SortControl < BaseComponent
        OPTIONS = {
          mentor: {
            label: "Mentor (A-Z)",
          },
          induction_start_date: {
            label: "Induction start date",
          },
        }.freeze

        def initialize(school:, selected:)
          @school = school
          @selected = selected.to_sym
        end

      private

        attr_reader :school, :selected

        def options
          @options ||= OPTIONS.keys
        end

        def option_label(option)
          OPTIONS.dig(option, :label)
        end

        def selected_option?(option)
          selected == option
        end
      end
    end
  end
end
