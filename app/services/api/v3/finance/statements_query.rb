# frozen_string_literal: true

module Api
  module V3
    module Finance
      class StatementsQuery
        include Concerns::FilterCohorts
        include Concerns::FilterUpdatedSince

        attr_reader :cpd_lead_provider, :params

        def initialize(cpd_lead_provider:, params:)
          @cpd_lead_provider = cpd_lead_provider
          @params = params
        end

        def statements
          scope = statement_class
            .includes(:cohort)
            .output
            .where(
              cpd_lead_provider:,
              cohort_id: cohorts.map(&:id),
            )

          if updated_since_filter.present?
            scope = scope.where(updated_at: updated_since..)
          end

          scope.order(payment_date: :asc)
        end

        def statement
          cpd_lead_provider.statements.find(params[:id])
        end

      private

        def statement_class
          return ::Finance::Statement if filter[:type].blank?
          return ::Finance::Statement.none unless ::Finance::Statement::STATEMENT_TYPES.include?(filter[:type])

          "::Finance::Statement::#{filter[:type].classify}".constantize
        end
      end
    end
  end
end
