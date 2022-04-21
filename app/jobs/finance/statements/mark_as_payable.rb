# frozen_string_literal: true

module Finance
  module Statements
    class MarkAsPayable < ApplicationJob
      def perform
        Finance::Statement.where(deadline_date: 1.day.ago.to_date).find_each do |statement|
          Finance::Statement.transaction do
            statement.participant_declarations.find_each(&:make_payable!)
            statement.payable!
          end
        end
      end
    end
  end
end
