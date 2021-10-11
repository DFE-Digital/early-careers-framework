# frozen_string_literal: true

module Api
  module V1
    class ParticipantValidationController < Api::ApiController
      include ApiTokenAuthenticatable

      def show
        record = ParticipantValidationService.validate(
          trn: params[:id],
          full_name: params[:full_name],
          date_of_birth: Date.iso8601(params[:date_of_birth]),
          nino: params[:nino],
          config: { check_first_name_only: true },
        )

        if record.present?
          render json: ParticipantValidationSerializer.new(OpenStruct.new(record)).serializable_hash.to_json
        else
          head :not_found
        end
      end

    private

      def access_scope
        ApiToken.where(private_api_access: true)
      end
    end
  end
end
