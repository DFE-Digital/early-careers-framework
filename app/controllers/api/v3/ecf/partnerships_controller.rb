# frozen_string_literal: true

module Api
  module V3
    module ECF
      class PartnershipsController <  Api::ApiController
        include ApiTokenAuthenticatable

        def create

        end

        private

        def partnership_params
          params
            .require(:data)
            .permit(:type, attributes: %i[cohort delivery_partner_id urn])
        end
      end
    end
  end
end
