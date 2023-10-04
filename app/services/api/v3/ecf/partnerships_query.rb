# frozen_string_literal: true

module Api
  module V3
    module ECF
      class PartnershipsQuery
        include Api::Concerns::FilterCohorts
        include Api::Concerns::FilterUpdatedSince
        include Concerns::Orderable

        attr_reader :lead_provider, :params

        def initialize(lead_provider:, params:)
          @lead_provider = lead_provider
          @params = params
        end

        def partnerships
          scope = partnership_scope
            .where(partnerships: { cohort: cohorts })
            .order(sort_order(default: "partnerships.created_at ASC", model: Partnership))
            .distinct

          if updated_since_filter.present?
            scope = scope.includes(:delivery_partner, school: [:induction_coordinators])
            scope = scope.where(partnerships: { updated_at: updated_since.. })
              .or(scope.where(school: { updated_at: updated_since.. }))
              .or(scope.where(delivery_partner: { updated_at: updated_since.. }))
              .or(scope.where(school: { users: { updated_at: updated_since.. } }))
          end

          scope = scope.where(partnerships: { delivery_partner: [delivery_partner_id_filter] }) if delivery_partner_id_filter.present?
          scope
        end

        def partnership
          partnership_scope.find(params[:id])
        end

      private

        def partnership_scope
          lead_provider.partnerships
            .includes(:cohort, :delivery_partner, school: :induction_coordinators)
            .where(relationship: false)
        end

        def delivery_partner_id_filter
          filter[:delivery_partner_id]&.split(",")
        end
      end
    end
  end
end
