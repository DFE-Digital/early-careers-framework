# frozen_string_literal: true

module Api
  module V3
    class Finance::StatementsController < Api::ApiController
      include ApiTokenAuthenticatable
      include ApiPagination
      include ApiFilter

      def index
        render json: Finance::StatementSerializer.new(paginate(finance_statements)).serializable_hash.to_json
      end

    private

      def finance_statements
        @finance_statements ||= finance_statements_query.statements
      end

      def finance_statements_query
        Finance::Statements::Index.new(
          cpd_lead_provider: current_user,
          params: statement_params,
        )
      end

      def statement_params
        params.permit(filter: %i[cohort type])
      end
    end
  end
end
