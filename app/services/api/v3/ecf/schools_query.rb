# frozen_string_literal: true

module Api
  module V3
    module ECF
      class SchoolsQuery
        include Concerns::FilterCohorts
        include Concerns::FilterUpdatedSince

        def initialize(params:)
          @params = params
        end

        def schools
          return School.none unless cohort_filter && cohort.present?

          scope = eligible_schools
            .not_cip_only
            .or(schools_with_existing_partnerships)
            .includes(partnerships: :cohort, school_cohorts: :cohort)
            .order(sort_order)
            .distinct

          scope = scope.where(urn: filter[:urn]) if filter[:urn].present?
          scope = scope.where(updated_at: updated_since..).or(scope.where(school_cohorts: { updated_at: updated_since.. })) if updated_since_filter.present?
          scope
        end

        def school
          schools.find_by!(id: params[:id])
        end

      private

        attr_reader :params

        def sort_order
          params[:sort].presence || "schools.created_at ASC"
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
              cohorts: { start_year: cohort_filter },
            })
        end
      end
    end
  end
end
