# frozen_string_literal: true

module Api
  module V3
    class ECFPartnershipsQuery
      attr_reader :lead_provider, :params

      def initialize(lead_provider:, params:)
        @lead_provider = lead_provider
        @params = params
      end

      def partnerships
        scope = lead_provider.partnerships.includes(:school, :cohort, :delivery_partner)
        scope = scope.where("partnerships.cohort_id IN (?)", with_cohorts.map(&:id)) if filter[:cohort].present?
        scope = scope.where("partnerships.updated_at > ?", updated_since) if updated_since.present?
        scope = scope.where("partnerships.delivery_partner_id IN (?)", delivery_partner_id_filter) if delivery_partner_id_filter.present?
        scope = scope.order("partnerships.updated_at DESC") if params[:sort].blank?
        scope
      end

    private

      def filter
        params[:filter] ||= {}
      end

      def delivery_partner_id_filter
        filter[:delivery_partner_id]&.split(",")
      end

      def updated_since
        return if filter[:updated_since].blank?

        Time.iso8601(filter[:updated_since])
      rescue ArgumentError
        Time.iso8601(URI.decode_www_form_component(filter[:updated_since]))
      end

      def with_cohorts
        return Cohort.where(start_year: filter[:cohort].split(",")) if filter[:cohort].present?

        Cohort.where("start_year > 2020")
      end
    end
  end
end
