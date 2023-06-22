# frozen_string_literal: true

module Api
  module V3
    class NPQApplicationsController < V1::NPQApplicationsController
      include ApiOrderable

      # Returns a list of NPQ applications
      # Providers can see their NPQ applications which cohorts they apply to via this endpoint
      #
      # GET /api/v3/npq-applications?filter[cohort]=2022&filter[updated_since]=2023-05-10%2015%3A00%3A00.000&filter[participant_id]=be483a5a-0bb3-4336-82fa-9bd0e4c58761&sort=name,-updated_at
      #
      def index
        render json: json_serializer_class.new(paginate(npq_applications)).serializable_hash.to_json
      end

    private

      def npq_applications
        @npq_applications ||= npq_applications_query.applications.order(sort_params(params))
      end

      def npq_applications_query
        Api::V3::NPQApplicationsQuery.new(
          npq_lead_provider:,
          params: npq_application_params,
        )
      end

      def npq_application_params
        params
          .with_defaults({ sort: "", filter: { updated_since: "", cohort: "", participant_id: "" } })
          .permit(:id, :sort, filter: %i[updated_since cohort participant_id])
      end

      def json_serializer_class
        Api::V3::NPQApplicationSerializer
      end
    end
  end
end
