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
            .or(schools_with_existing_partnerships)
            .includes(partnerships: :cohort, school_cohorts: :cohort)
            .distinct
          scope = scope.where(urn: filter[:urn]) if filter[:urn].present?
          scope = scope.order(updated_at: :desc) if params[:sort].blank?
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
              cohorts: { start_year: filter[:cohort] },
            })
        end
      end
    end
  end
end
