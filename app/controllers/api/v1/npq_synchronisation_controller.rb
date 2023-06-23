# frozen_string_literal: true

module Api
  module V1
    class NPQSynchronisationController < Api::ApiController
      def send_lead_provider_approval_status_to_npq
        render json: json_accounts_serializer_class.new(NPQApplication.all).serializable_hash.to_json
      end

    private

      def json_accounts_serializer_class
        Api::V1::NPQAccountsPageSerializer
      end
    end
  end
end
