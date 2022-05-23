# frozen_string_literal: true

module DeliveryPartners
  class ParticipantsController < BaseController
    def index
      collection = ParticipantProfile::ECF.includes(
        induction_records: {
          induction_programme: [:partnership],
        },
      ).where(
        induction_records: {
          induction_programme: {
            partnerships: {
              delivery_partner: current_user.delivery_partner_profile.delivery_partner,
              challenged_at: nil,
              challenge_reason: nil,
              pending: false,
            },
          },
        },
      )

      @filter = ParticipantsFilter.new(collection: collection, params: params.permit(:query, :role, :academic_year, :status))

      @pagy, @participant_profiles = pagy(
        @filter.scope.order(updated_at: :desc),
        page: params[:page],
        items: 50,
      )
    end
  end
end
