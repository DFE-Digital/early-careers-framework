# frozen_string_literal: true

module Finance
  module Statements
    class MarkAsPayable < ApplicationJob
      def perform
        Finance::Statement.where(deadline_date: 1.day.ago.to_date).find_each do |statement|
          Finance::Statement.transaction do
            statement.payable!

            statement
              .participant_declarations
              .billable
              .find_each do |declaration|
              declaration.make_payable!

              line_item = StatementLineItem.find_by(statement: statement, participant_declaration: declaration)

              line_item.update!(state: "payable") if line_item
            end
          end
        end
      end
    end
  end
end
