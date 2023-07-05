# frozen_string_literal: true

module Api
  module V3
    module Finance
      class StatementsQuery
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
              cohort_id: with_cohorts.map(&:id),
            )

          if updated_since.present?
            scope = scope.where(updated_at: updated_since..)
          end

          scope.order(payment_date: :asc)
        end

        def statement
          cpd_lead_provider.statements.find(params[:id])
        end

      private

        def filter
          params[:filter] ||= {}
        end

        def with_cohorts
          return Cohort.where(start_year: filter[:cohort].split(",")) if filter[:cohort].present?

          Cohort.national_rollout_year
        end

        def statement_class
          return ::Finance::Statement if filter[:type].blank?
          return ::Finance::Statement.none unless ::Finance::Statement::STATEMENT_TYPES.include?(filter[:type])

          "::Finance::Statement::#{filter[:type].classify}".constantize
        end

        def updated_since
          return if filter[:updated_since].blank?

          Time.iso8601(filter[:updated_since])
        rescue ArgumentError
          begin
            Time.iso8601(URI.decode_www_form_component(filter[:updated_since]))
          rescue ArgumentError
            raise Api::Errors::InvalidDatetimeError, I18n.t(:invalid_updated_since_filter)
          end
        end
      end
    end
  end
end
