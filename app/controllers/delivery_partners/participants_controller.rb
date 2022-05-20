# frozen_string_literal: true

module DeliveryPartners
  class ParticipantsController < BaseController
    def index
      collection = current_user.delivery_partner_profile.delivery_partner.ecf_participant_profiles
      @filter = ParticipantsFilter.new(collection: collection, params: params.permit(:query, :role, :academic_year, :status))

      @pagy, @participant_profiles = pagy(
        @filter.scope.order(updated_at: :desc),
        page: params[:page],
        items: 50,
      )
    end
  end
end
