# frozen_string_literal: true

module Api
  module V3
    module ECF
      class SchoolsQuery
        def initialize(params:)
          @params = params
        end

        def schools
          scope = SchoolCohort.includes(:cohort, school: :partnerships)
          scope = scope.where(cohort: { start_year: filter[:cohort] })
          scope = scope.where(schools: { urn: filter[:urn] }) if filter[:urn].present?
          scope = scope.order("schools.updated_at DESC") if params[:sort].blank?
          scope
        end

      private

        attr_reader :params

        def filter
          params[:filter] ||= {}
        end
      end
    end
  end
end
