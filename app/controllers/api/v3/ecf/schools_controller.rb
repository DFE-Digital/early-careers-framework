# frozen_string_literal: true

module Api
  module V3
    module ECF
      class SchoolsController < Api::ApiController
        include ApiTokenAuthenticatable
        include ApiPagination
        include ApiFilterValidation
        include ApiOrderable

        filter_validation required_filters: %i[cohort]

        # Retrieve multiple ECF schools scoped to cohort
        #
        # GET /api/v3/schools/ecf?filter[cohort]=2021&sort=-updated_at
        #
        def index
          render json: serializer_class.new(paginate(ecf_schools), params: { cohort: }).serializable_hash.to_json
        end

        # Retrieve a single ECF school scoped to cohort
        #
        # GET /api/v3/schools/ecf/:school_id?filter[cohort]=2021
        #
        def show
          render json: serializer_class.new(ecf_school, params: { cohort: }).serializable_hash.to_json
        end

      private

        def ecf_schools
          @ecf_schools ||= ecf_schools_query.schools
        end

        def ecf_school
          @ecf_school ||= ecf_schools_query.school
        end

        def ecf_schools_query
          Api::V3::ECF::SchoolsQuery.new(
            params: school_params,
          )
        end

        def access_scope
          LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider])
        end

        def serializer_class
          Api::V3::ECF::SchoolSerializer
        end

        def school_params
          params
            .with_defaults({ filter: { cohort: "", urn: "", updated_since: "" } })
            .permit(:id, filter: %i[cohort urn updated_since])
            .merge(sort: sort_params)
        end

        def cohort
          Cohort.find_by(start_year: school_params[:filter][:cohort])
        end
      end
    end
  end
end
