# frozen_string_literal: true

module Api
  module V3
    module Finance
      module Statements
        class Index
          attr_reader :cpd_lead_provider, :params

          def initialize(cpd_lead_provider:, params:)
            @cpd_lead_provider = cpd_lead_provider
            @params = params
          end

          def statements
            statement_class
              .includes(:cohort)
              .output
              .where(
                cpd_lead_provider:,
                cohort_id: with_cohorts.map(&:id),
              ).order(payment_date: :asc)
          end

        private

          def filter
            params[:filter] ||= {}
          end

          def with_cohorts
            return Cohort.where(start_year: filter[:cohort].split(",")) if filter[:cohort].present?

            Cohort.where("start_year > 2020")
          end

          def statement_class
            return ::Finance::Statement if filter[:type].blank?
            return ::Finance::Statement.none unless ::Finance::Statement::STATEMENT_TYPES.include?(filter[:type])

            "::Finance::Statement::#{filter[:type].classify}".constantize
          end
        end
      end
    end
  end
end
