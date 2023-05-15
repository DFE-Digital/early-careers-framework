# frozen_string_literal: true

module Api
  module V3
    class NPQApplicationsController < V1::NPQApplicationsController
      include ApiOrderable

      # Returns a list of NPQ applications
      # Providers can see their NPQ applications which cohorts they apply to via this endpoint
      #
      # GET /api/v3/npq-applications?filter[cohort]=2022&sort=name,-updated_at
      #
      def index
        render json: json_serializer_class.new(paginate(query_scope.order(sort_params(params)))).serializable_hash.to_json
      end

    private

      def json_serializer_class
        Api::V3::NPQApplicationSerializer
      end
    end
  end
end
