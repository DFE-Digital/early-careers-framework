# frozen_string_literal: true

module Finance
  module Statements
    class ECFStatementSelector < BaseComponent
      attr_reader :current_statement, :cohorts

      def initialize(current_statement:, cohorts:)
        @current_statement = current_statement
        @cohorts = cohorts
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
              name:,
            )
          end
      end

      def t(key)
        I18n.t key, scope: i18n_scope
      end

    private

      def i18n_scope
        %i[components finance statements ecf_statement_selector]
      end
    end
  end
end
