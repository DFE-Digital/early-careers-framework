# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V3
    class DeliveryPartnerSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      set_id :id
      set_type :'delivery-partner'
      attributes :name

      attribute :updated_at do |delivery_partner|
        delivery_partner.updated_at.rfc3339
      end

      attribute :cohort do |delivery_partner|
        delivery_partner.lead_providers.map { |lead_provider| delivery_partner.cohorts_with_provider(lead_provider).map(&:start_year) }.flatten
      end
    end
  end
end
