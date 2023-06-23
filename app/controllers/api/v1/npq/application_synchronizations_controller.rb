module Api
  module V1
    module NPQ
      class ApplicationSynchronizationsController < ApiController
        def index
          render json: json_accounts_serializer_class.new(NPQApplication.all).serializable_hash.to_json
        end

        private

        def json_accounts_serializer_class
          Api::V1::NPQ::ApplicationSynchronizationSerializer
        end
      end
    end
  end
end