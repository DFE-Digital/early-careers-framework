# frozen_string_literal: true

module Api
  module V3
    module DeliveryPartners
      class Show
        attr_reader :lead_provider, :params

        def initialize(lead_provider:, params:)
          @lead_provider = lead_provider
          @params = params
        end

        def delivery_partner
          lead_provider.delivery_partners.find_by("delivery_partners.id = ?", params[:id])
        end
      end
    end
  end
end
