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

      attribute :created_at do |delivery_partner|
        delivery_partner.created_at.rfc3339
      end

      attribute :updated_at do |delivery_partner|
        delivery_partner.updated_at.rfc3339
      end

      attribute :cohort do |delivery_partner, params|
        delivery_partner.cohorts_with_provider(params[:lead_provider]).map(&:display_name).sort
      end
    end
  end
end
