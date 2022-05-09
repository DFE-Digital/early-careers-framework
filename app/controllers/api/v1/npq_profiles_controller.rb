# frozen_string_literal: true

module Api
  module V1
    class NPQProfilesController < Api::ApiController
      include ApiTokenAuthenticatable

      def show
        @npq_application = NPQApplication.find params[:id]
        render json: NPQValidationDataSerializer.new(@npq_application).serializable_hash
      end

      def create
        @npq_application = build_npq_application

        if @npq_application.save
          render status: :created,
                 content_type: "application/vnd.api+json",
                 json: NPQValidationDataSerializer.new(@npq_application).serializable_hash
        else
          render json: { errors: Api::ErrorFactory.new(model: @npq_application).call }, status: :bad_request
        end
      end

      def update
        @npq_application = NPQApplication.find params[:id]

        if @npq_application.update(npq_application_update_params)
          render status: :ok,
                 content_type: "application/vnd.api+json",
                 json: NPQValidationDataSerializer.new(@npq_application).serializable_hash
        else
          render json: { errors: Api::ErrorFactory.new(model: @npq_application).call }, status: :bad_request
        end
      end

    private

      def access_scope
        ApiToken.where(private_api_access: true)
      end

      def build_npq_application
        NPQ::BuildApplication.call(
          npq_application_params: npq_application_params,
          npq_course_id: npq_course_id,
          npq_lead_provider_id: npq_lead_provider_id,
          user_id: user_id,
        )
      end

      def npq_course_id
        params.require(:data)
          .require(:relationships)
          .require(:npq_course)
          .require(:data)
          .permit(:id)[:id]
      end

      def npq_lead_provider_id
        params.require(:data)
          .require(:relationships)
          .require(:npq_lead_provider)
          .require(:data)
          .permit(:id)[:id]
      end

      def user_id
        params.require(:data)
          .require(:relationships)
          .require(:user)
          .require(:data)
          .permit(:id)[:id]
      end

      def npq_application_params
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
            :school_ukprn,
            :teacher_reference_number,
            :teacher_reference_number_verified,
            :works_in_school,
            :employer_name,
            :employment_role,
            :targeted_support_funding_eligibility,
          ).transform_keys! { |key| key == "national_insurance_number" ? "nino" : key }
      end

      def npq_application_update_params
        params
          .require(:data)
          .permit(attributes: :eligible_for_funding)
      end
    end
  end
end
