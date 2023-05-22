# frozen_string_literal: true

module Api
  module V3
    module ECF
      class SchoolsQuery
        def initialize(params:)
          @params = params
        end

        def schools
          return School.none unless filter[:cohort] && cohort.present?

          scope = eligible_schools
            .not_cip_only
            .or(schools_with_existing_partnerships)
            .includes(partnerships: :cohort, school_cohorts: :cohort)
            .distinct

          scope = scope.where(urn: filter[:urn]) if filter[:urn].present?
          scope = scope.order("schools.created_at ASC") if params[:sort].blank?

          if updated_since.present?
            scope = scope.where(updated_at: updated_since..).or(scope.where(school_cohorts: { updated_at: updated_since.. }))
          end

          scope
        end

        def school
          schools.find_by!(id: params[:id])
        end

      private

        attr_reader :params

        def filter
          params[:filter] ||= {}
        end

        def cohort
          Cohort.find_by(start_year: filter[:cohort])
        end

        def eligible_schools
          School.eligible
        end

        def schools_with_existing_partnerships
          School
            .where.not(partnerships: { id: nil })
            .where(partnerships: {
              challenged_at: nil,
              challenge_reason: nil,
              relationship: false,
              cohorts: { start_year: filter[:cohort] },
            })
        end

        def updated_since
          return if filter[:updated_since].blank?

          Time.iso8601(filter[:updated_since])
        rescue ArgumentError
          begin
            Time.iso8601(URI.decode_www_form_component(filter[:updated_since]))
          rescue ArgumentError
            raise Api::Errors::InvalidDatetimeError, I18n.t(:invalid_updated_since_filter)
          end
        end
      end
    end
  end
end
