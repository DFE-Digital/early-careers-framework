# frozen_string_literal: true

module DeliveryPartners
  class ParticipantsController < BaseController
    def index
      induction_records = InductionRecordsQuery.new(delivery_partner:).induction_records
      @training_record_states = DetermineTrainingRecordState.call(induction_records:)
      @filter = ParticipantsFilter.new(collection: induction_records, params: filter_params, training_record_states: @training_record_states)

      respond_to do |format|
        format.html do
          @pagy, @induction_records = pagy(
            @filter.scope.order(updated_at: :desc),
            page: params[:page],
            items: 50,
          )
        end

        format.csv do
          serializer = InductionRecordsSerializer.new(@filter.scope.order(updated_at: :desc), params: { training_record_states: @training_record_states })
          render body: to_csv(serializer.serializable_hash)
        end
      end
    end

  private

    def delivery_partner
      @delivery_partner ||= current_user.delivery_partners.find(params[:delivery_partner_id])
    end

    helper_method :delivery_partner

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

    def filter_params
      params.permit(:query, :role, :academic_year, :status).merge(delivery_partner:)
    end
  end
end
