# frozen_string_literal: true

module Api
  module V1
    class DqtRecordsController < Api::ApiController
      include ApiTokenAuthenticatable

      def show
        hash = Dqt::Client.new.api.dqt_record.show(params: { teacher_reference_number: params[:id] })

        if hash.present?
          render json: DqtRecordSerializer.new(OpenStruct.new(hash)).serializable_hash.to_json
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
