# frozen_string_literal: true

module Finance
  module ECF
    class BreakdownSummary < BaseComponent
      attr_accessor :name, :declaration, :recruitment_target, :ects, :mentors, :participants

    private

      def initialize(breakdown_summary:)
        breakdown_summary.each do |param, value|
          send("#{param}=", value)
        end
      end
    end
  end
end
