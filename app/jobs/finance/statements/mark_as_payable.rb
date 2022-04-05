# frozen_string_literal: true

module Finance
  module Statements
    class MarkAsPayable < ApplicationJob
      def perform
        Finance::Statement.where(deadline_date: 1.day.ago.to_date).find_each do |statement|
          statement
            .participant_declarations
            .where
            .not(state: ParticipantDeclaration.states.values_at(:voided, :ineligible))
            .find_each(&:make_payable!)
        end
      end
    end
  end
end
