# frozen_string_literal: true

module Api
  module V1
    class ActiveModelErrorsSerializer
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Serialization

      attribute :title
      attribute :detail

      def self.from(service)
        {
          errors: service
            .errors
            .messages
            .map { |title, detail| new(title:, detail: detail.uniq.join(", ")).serializable_hash },
        }
      end
    end
  end
end
