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

      @filter = ParticipantsFilter.new(collection:, params: params.permit(:query, :role, :academic_year, :status))

      respond_to do |format|
        format.html do
          @pagy, @participant_profiles = pagy(
            @filter.scope.order(updated_at: :desc),
            page: params[:page],
            items: 50,
          )
        end

        format.csv do
          serializer = DeliveryPartners::ParticipantsSerializer.new(
            @filter.scope.order(updated_at: :desc),
            params: {
              delivery_partner: current_user.delivery_partner_profile.delivery_partner,
            },
          )
          render body: to_csv(serializer.serializable_hash)
        end
      end
    end

  private

    def to_csv(hash)
      return "" if hash[:data].empty?

      attributes = hash[:data].first[:attributes].keys
      headers = attributes.map(&:to_s)
      CSV.generate(headers:, write_headers: true) do |csv|
        hash[:data].each do |item|
          csv << attributes.map { |attribute| item[:attributes][attribute].to_s }
        end
      end
    end
  end
end
