# frozen_string_literal: true

module Finance
  module Statements
    class MarkAsPayable < ApplicationJob
      def perform
        Finance::Statement.where(deadline_date: 1.day.ago.to_date).find_each do |statement|
          ::Statements::MarkAsPayable.new(statement).call
        end
      end
    end
  end
end
