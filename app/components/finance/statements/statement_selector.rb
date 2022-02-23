# frozen_string_literal: true

module Finance
  module Statements
    class StatementSelector < BaseComponent
      attr_reader :current_statement

      def initialize(current_statement:)
        @current_statement = current_statement
      end

      def npq_lead_providers
        NPQLeadProvider.all
      end

      def statements
        Finance::Statement::NPQ
          .distinct(:name)
          .pluck(:name)
          .map do |name|
            OpenStruct.new(
              id: name.downcase.gsub(" ", "-"),
              name: name,
            )
          end
      end
    end
  end
end
