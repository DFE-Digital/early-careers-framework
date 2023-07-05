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
        # The subquery is an optimization so that we don't have to perform
        # a separate query for each record as part of NPQApplication#previously_funded?
        scope = all_applications.select(
          "npq_applications.*",
          "EXISTS(
            WITH json_data(alt_courses) AS (VALUES ('#{ActiveRecord::Base.sanitize_sql(alternative_courses)}'::jsonb))
            SELECT 1 AS one FROM npq_applications AS a, json_data
              WHERE a.id != npq_applications.id AND
                    a.participant_identity_id = npq_applications.participant_identity_id AND
                    a.eligible_for_funding = true AND
                    a.lead_provider_approval_status = 'accepted' AND
                    a.npq_course_id IN (
                      SELECT jsonb_array_elements_text(alt_courses->(npq_applications.npq_course_id::text))::uuid
                      FROM json_data
                    )
              LIMIT 1
          ) AS transient_previously_funded",
        )

        scope = apply_cohorts_filter(scope)
        scope = apply_updated_since_filter(scope)
        scope = apply_participant_id_filter(scope)
        apply_default_sort(scope)
      end

    private

      def alternative_courses
        NPQCourse
          .all
          .each_with_object({}) { |c, h| h[c.id] = c.rebranded_alternative_courses.map(&:id) }
          .to_json
      end

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
                    Cohort.national_rollout_year
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
