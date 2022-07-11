# frozen_string_literal: true

module Api
  module V2
    class NPQApplicationsController < V1::NPQApplicationsController
    private

      def json_serializer_class
        NPQApplicationSerializer
      end

      def csv_serializer_class
        NPQApplicationCsvSerializer
      end
    end
  end
end
