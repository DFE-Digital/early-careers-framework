# frozen_string_literal: true

module Finance
  module Statements
    class MarkAsPaidJob < ApplicationJob
      sidekiq_options retry: false

      def perform(statement_id:)
        return unless statement_id

        statement = Finance::Statement.find_by(id: statement_id)

        if statement.present?
          ::Statements::MarkAsPaid.new(statement).call
        else
          Rails.logger.warn("Statement could not be found - statement_id: #{statement_id}")
        end
      end
    end
  end
end
