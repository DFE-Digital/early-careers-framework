module Api
  module V1
    module NPQ
      class ApplicationSynchronizationsController < ApiController
        before_action :all_applications
        def index
          render json: json_accounts_serializer_class.new(@npq_applications).serializable_hash.to_json
        end

        private

        def all_applications
          @npq_applications = NPQApplication.all.select(:lead_provider_approval_status, :id, :participant_identity_id)
        end

        def json_accounts_serializer_class
          Api::V1::NPQ::ApplicationSynchronizationSerializer
        end
      end
    end
  end
end