# frozen_string_literal: true

module Api
  module V3
    class NPQApplicationsQuery
      attr_reader :npq_lead_provider, :params

      def initialize(npq_lead_provider:, params:)
        @npq_lead_provider = npq_lead_provider
        @params = params
      end

      def applications
        scope = all_applications

        scope = apply_cohorts_filter(scope)
        scope = apply_updated_since_filter(scope)
        scope = apply_participant_id_filter(scope)
        apply_default_sort(scope)
      end

    private

      def filter
        params[:filter] ||= {}
      end

      def updated_since_filter
        filter[:updated_since]
      end

      def apply_default_sort(scope)
        return scope if params[:sort].present?

        scope.order("npq_applications.created_at ASC")
      end

      def all_applications
        npq_lead_provider
          .npq_applications
          .includes(
            :cohort,
            :npq_course,
            :profile,
            participant_identity: [:user],
          )
      end

      def apply_updated_since_filter(scope)
        return scope if updated_since_filter.blank?

        scope.where("updated_at > ?", updated_since)
      end

      def apply_participant_id_filter(scope)
        participant_id_filter = filter[:participant_id]

        return scope if participant_id_filter.blank?

        scope.where(participant_identity: { users: { id: participant_id_filter } })
      end

      def apply_cohorts_filter(scope)
        cohort_filter = filter[:cohort].to_s
        cohorts = if cohort_filter.present?
                    Cohort.where(start_year: cohort_filter.split(","))
                  else
                    Cohort.where("start_year > 2020")
                  end

        scope.where(cohort: cohorts)
      end

      def updated_since
        Time.iso8601(updated_since_filter)
      rescue ArgumentError
        begin
          Time.iso8601(URI.decode_www_form_component(updated_since_filter))
        rescue ArgumentError
          raise Api::Errors::InvalidDatetimeError, I18n.t(:invalid_updated_since_filter)
        end
      end
    end
  end
end
