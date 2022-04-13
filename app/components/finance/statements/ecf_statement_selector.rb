# frozen_string_literal: true

module Finance
  module Statements
    class ECFStatementSelector < BaseComponent
      attr_reader :current_statement

      def initialize(current_statement:)
        @current_statement = current_statement
      end

      def lead_providers
        LeadProvider.order(:name)
      end

      def statements
        Finance::Statement::ECF.order(:payment_date)
          .pluck(:name)
          .uniq
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
