# frozen_string_literal: true

module AppropriateBodies
  class ParticipantsController < BaseController
    def index
      collection = InductionRecord.includes(:participant_profile).where(appropriate_body:)

      @filter = ParticipantsFilter.new(collection:, params: filter_params)

      respond_to do |format|
        format.html do
          @pagy, @induction_records = pagy(
            @filter.scope.order(updated_at: :desc),
            page: params[:page],
            items: 50,
          )
        end

        format.csv do
          serializer = InductionRecordsSerializer.new(@filter.scope.order(updated_at: :desc))
          render body: to_csv(serializer.serializable_hash)
        end
      end
    end

  private

    def appropriate_body
      @appropriate_body ||= current_user.appropriate_bodies.find(params[:appropriate_body_id])
    end

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
      params.permit(:query, :role, :academic_year, :status)
    end
  end
end
