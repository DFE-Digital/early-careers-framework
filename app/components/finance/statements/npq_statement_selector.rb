# frozen_string_literal: true

module Finance
  module Statements
    class NPQStatementSelector < BaseComponent
      attr_reader :current_statement

      def initialize(current_statement:)
        @current_statement = current_statement
      end

      def npq_lead_providers
        NPQLeadProvider.order(:name)
      end

      def statements
        Finance::Statement::NPQ.order(:payment_date)
          .pluck(:name)
          .uniq
          .map do |name|
            OpenStruct.new(
              id: name.downcase.gsub(" ", "-"),
              name:,
            )
          end
      end

      private

      def cohorts
        Cohort.where(start_year: 2021..)
      end
    end
  end
end
