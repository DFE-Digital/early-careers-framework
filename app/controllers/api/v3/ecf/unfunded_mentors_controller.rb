# frozen_string_literal: true

module Api
  module V3
    module ECF
      class UnfundedMentorsController < Api::ApiController
        include ApiTokenAuthenticatable
        include ApiPagination
        include ApiFilter
        include ApiOrderable

        # Returns a list of ECF Unfunded Mentors
        # Providers can see their ECF Unfunded Mentors details via this endpoint
        #
        # GET /api/v3/unfunded-mentors/ecf?filter[updated_since]=2022-11-13T11:21:55Z&sort=-updated_at,full_name
        #
        def index
          render json: serializer_class.new(paginate(ecf_unfunded_mentors)).serializable_hash.to_json
        end

        # Returns a single ECF Unfunded Mentor
        # Providers can see a specific ECF Unfunded Mentor details via this endpoint
        #
        # GET /api/v3/unfunded-mentors/ecf/:id
        def show
          render json: serializer_class.new(ecf_unfunded_mentor).serializable_hash.to_json
        end

      private

        def lead_provider
          @lead_provider ||= current_user.lead_provider
        end

        def ecf_unfunded_mentors
          @ecf_unfunded_mentors ||= ecf_unfunded_mentors_query.unfunded_mentors.order(sort_params(params, model: User))
        end

        def ecf_unfunded_mentor
          @ecf_unfunded_mentor ||= ecf_unfunded_mentors_query.unfunded_mentor
        end

        def ecf_unfunded_mentors_query
          Api::V3::ECF::UnfundedMentorsQuery.new(
            lead_provider:,
            params: unfunded_mentor_params,
          )
        end

        def access_scope
          LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider])
        end

        def serializer_class
          Api::V3::ECF::UnfundedMentorSerializer
        end

        def unfunded_mentor_params
          params
            .with_defaults({ sort: "", filter: { updated_since: "" } })
            .permit(:id, :sort, filter: %i[updated_since])
        end
      end
    end
  end
end
