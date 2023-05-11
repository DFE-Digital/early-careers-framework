# frozen_string_literal: true

module Api
  module V3
    class NPQApplicationsController < V1::NPQApplicationsController
      def index
        render json: json_serializer_class.new(paginate(query_scope)).serializable_hash.to_json
      end
    end
  end
end
