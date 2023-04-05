# frozen_string_literal: true

module Api
  module V3
    module ECF
      class PartnershipsController < Api::ApiController
        include ApiTokenAuthenticatable
        include ApiPagination
        include ApiFilter
        include ApiOrderable

        # Returns a list of partnerships
        # Providers can see their partnerships via this endpoint
        #
        # GET /api/v3/partnerships/ecf?filter[cohort]=2021,2022&sort=-updated_at,challenge_reason
        #
        def index
          render json: serializer_class.new(paginate(ecf_partnerships)).serializable_hash.to_json
        end

        # Returns a specific ECF partnership given its ID
        # Providers can see a specific ECF partnership and which cohorts it applies to via this endpoint
        #
        # GET /api/v1/partnerships/ecf/:id
        #
        def show
          render json: serializer_class.new(ecf_partnership).serializable_hash.to_json
        end

      private

        def lead_provider
          @lead_provider ||= current_user.lead_provider
        end

        def ecf_partnerships
          @ecf_partnerships ||= ecf_partnerships_query.partnerships.order(sort_params(params))
        end

        def ecf_partnership
          @ecf_partnership ||= ecf_partnerships_query.partnership
        end

        def ecf_partnerships_query
          Api::V3::ECF::PartnershipsQuery.new(
            lead_provider:,
            params: ecf_partnership_params,
          )
        end

        def ecf_partnership_params
          params
            .with_defaults({ sort: "", filter: { delivery_partner_id: "", updated_since: "", cohort: "" } })
            .permit(:id, :sort, filter: %i[cohort updated_since delivery_partner_id])
        end

        def access_scope
          LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider])
        end

        def serializer_class
          Api::V3::ECF::PartnershipSerializer
        end
      end
    end
  end
end
