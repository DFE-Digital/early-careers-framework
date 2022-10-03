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
              .where(
                cpd_lead_provider:,
                cohort_id: with_cohorts.map(&:id),
              ).order(created_at: :asc)
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

            case filter[:type]
            when "ecf"
              ::Finance::Statement::ECF
            when "npq"
              ::Finance::Statement::NPQ
            else
              ::Finance::Statement.none
            end
          end
        end
      end
    end
  end
end
