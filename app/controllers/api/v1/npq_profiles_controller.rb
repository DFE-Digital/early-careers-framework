# frozen_string_literal: true

module Api
  module V1
    class NPQProfilesController < Api::ApiController
      include ApiTokenAuthenticatable

      def create
        validation_data = NPQValidationData.new(validation_data_params)
        validation_data.npq_course = NPQCourse.find_by(id: npq_course_param)
        validation_data.npq_lead_provider = NPQLeadProvider.find_by(id: npq_lead_provider_param)
        validation_data.user = User.find_by(id: user_param)

        if validation_data.save
          render status: :created,
                 content_type: "application/vnd.api+json",
                 json: NPQValidationDataSerializer.new(validation_data).serializable_hash
        else
          render json: { errors: Api::ErrorFactory.new(model: validation_data).call }, status: :bad_request
        end
      end

    private

      def access_scope
        ApiToken.where(private_api_access: true)
      end

      def npq_course_param
        params[:data][:relationships][:npq_course][:data][:id]
      end

      def npq_lead_provider_param
        params[:data][:relationships][:npq_lead_provider][:data][:id]
      end

      def user_param
        params[:data][:relationships][:user][:data][:id]
      end

      def validation_data_params
        params
          .require(:data)
          .require(:attributes)
          .permit(
            :active_alert,
            :date_of_birth,
            :eligible_for_funding,
            :funding_choice,
            :headteacher_status,
            :national_insurance_number,
            :school_urn,
            :teacher_reference_number,
            :teacher_reference_number_verified,
          ).transform_keys! { |key| key == "national_insurance_number" ? "nino" : key }
      end
    end
  end
end
