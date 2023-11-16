# frozen_string_literal: true

module Api
  module V3
    class NPQApplicationsController < V1::NPQApplicationsController
      # Returns a list of NPQ applications
      # Providers can see their NPQ applications which cohorts they apply to via this endpoint
      #
      # GET /api/v3/npq-applications?filter[cohort]=2022&filter[updated_since]=2023-05-10%2015%3A00%3A00.000&filter[participant_id]=be483a5a-0bb3-4336-82fa-9bd0e4c58761&sort=name,-updated_at
      #
      def index
        render json: json_serializer_class.new(paginate(npq_applications)).serializable_hash.to_json
      end

      # Accepts an NPQ application
      # Providers can accept an NPQ application via this endpoint
      #
      # POST /api/v3/npq-applications/:id/accept
      #
      def accept
        service = ::NPQ::Application::Accept.new({ npq_application: }.merge(accept_npq_application_params["attributes"] || {}))

        render_from_service(service, json_serializer_class)
      end

    private

      def npq_applications
        @npq_applications ||= npq_applications_query.applications
      end

      def npq_applications_query
        Api::V3::NPQApplicationsQuery.new(
          npq_lead_provider:,
          params: npq_application_params,
        )
      end

      def npq_application_params
        params
          .with_defaults(sort: "", filter: { updated_since: "", cohort: "", participant_id: "" })
          .permit(:id, :sort, filter: %i[updated_since cohort participant_id])
      end

      def json_serializer_class
        Api::V3::NPQApplicationSerializer
      end

      def accept_npq_application_params
        return {} unless FeatureFlag.active?(:accept_npq_application_can_change_schedule)

        parameters = params
          .fetch(:data)
          .permit(:type, attributes: %i[schedule_identifier])

        return parameters unless parameters["attributes"].empty?

        raise ActionController::BadRequest, I18n.t(:invalid_data_structure)
      rescue ActionController::ParameterMissing
        {}
      end
    end
  end
end
