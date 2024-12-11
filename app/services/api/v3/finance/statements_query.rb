# frozen_string_literal: true

module Api
  module V3
    module Finance
      class StatementsQuery
        include Api::Concerns::FilterCohorts
        include Api::Concerns::FilterUpdatedSince

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
          statement_class.where(cpd_lead_provider:).find(params[:id])
        end

      private

        def statement_class
          if filter[:type].blank? || filter[:type] == "ecf"
            ::Finance::Statement::ECF
          else
            ::Finance::Statement.none
          end
        end
      end
    end
  end
end
