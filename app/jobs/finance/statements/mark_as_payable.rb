module Statements
  class MarkAsPayable < ApplicationJob
    def perform
      Finance::Statement.where(deadline_date: 1.day.ago.to_date).find_each do |statement|
        statement
          .participant_declarations
          .where
          .not(state: ParticipantDeclaration.states.values_at(:voided, :ineligible))
          .find_each(&:mark_as_payable!)
      end
    end
  end
end
