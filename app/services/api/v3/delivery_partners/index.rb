# frozen_string_literal: true

module Api
  module V3
    module DeliveryPartners
      class Index
        attr_reader :lead_provider, :params

        def initialize(lead_provider:, params:)
          @lead_provider = lead_provider
          @params = params
        end

        def delivery_partners
          scope = lead_provider.delivery_partners
          scope = scope.where("provider_relationships.cohort_id IN (?)", with_cohorts.map(&:id)) if filter[:cohort].present?
          scope = scope.order("delivery_partners.updated_at DESC") if params[:sort].blank?
          scope
        end

      private

        def filter
          params[:filter] ||= {}
        end

        def with_cohorts
          return Cohort.where(start_year: filter[:cohort].split(",")) if filter[:cohort].present?

          Cohort.where("start_year > 2020")
        end
      end
    end
  end
end
