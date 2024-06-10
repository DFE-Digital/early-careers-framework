# frozen_string_literal: true

module SemanticLogger
  module Formatters
    class JsonWithApiMetadata < Raw
      def call(log, logger)
        super(log, logger).merge(api_metrics).to_json
      end

    private

      def api_metrics
        return {} unless payload

        {
          params: payload[:params],
          exception: payload[:exception],
          current_user_class: payload[:current_user_class],
          current_user_id: payload[:current_user_id],
        }.compact
      end
    end
  end
end
