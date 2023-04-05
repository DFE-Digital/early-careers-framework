# frozen_string_literal: true

module Api
  module V3
    module ECF
      class SchoolsController < Api::ApiController
        include ApiTokenAuthenticatable
        include ApiPagination
        include ApiFilter
        include ApiOrderable

        # Retrieve multiple ECF schools scoped to cohort
        #
        # GET /api/v3/schools/ecf?filter[cohort]=2021&sort=-updated_at
        #
        def index
          render json: serializer_class.new(paginate(ecf_schools)).serializable_hash.to_json
        end

        # Retrieve a single ECF school scoped to cohort
        #
        # GET /api/v3/schools/ecf/:school_id?filter[cohort]=2021
        #
        def show
          render json: serializer_class.new(ecf_school).serializable_hash.to_json
        end

      private

        def ecf_schools
          @ecf_schools ||= ecf_schools_query.schools.order(sort_params(params))
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
          Api::V3::ECF::SchoolCohortSerializer
        end

        def required_filter_params
          %i[cohort]
        end

        def school_params
          params
            .with_defaults({ filter: { cohort: "", urn: "" } })
            .permit(:id, :sort, filter: %i[cohort urn])
        end
      end
    end
  end
end
