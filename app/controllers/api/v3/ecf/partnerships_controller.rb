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
        # GET /api/v3/partnerships/ecf/:id
        #
        def show
          render json: serializer_class.new(ecf_partnership).serializable_hash.to_json
        end

        # Creates a new ECF partnership
        # Providers can see create a new partnership via this endpoint
        #
        # POST /api/v3/partnerships/ecf
        #
        def create
          service = ::Partnerships::Create.new(partnership_params)

          render_from_service(service, serializer_class)
        end

        # Updates a specific ECF partnership given its ID
        # Providers can see update a partnership with new delivery partner via this endpoint
        #
        # PUT /api/v3/partnerships/ecf/:id
        #
        def update
          service = ::Partnerships::Update.new(
            partnership: ecf_partnership,
            delivery_partner_id: partnership_params[:delivery_partner_id],
          )

          render_from_service(service, serializer_class)
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

        def permitted_params
          params.require(:data).permit(:type, attributes: %i[cohort school_id delivery_partner_id])
        rescue ActionController::ParameterMissing => e
          if e.param == :data
            raise ActionController::BadRequest, I18n.t(:invalid_data_structure)
          else
            raise
          end
        end

        def partnership_params
          HashWithIndifferentAccess.new(
            lead_provider_id: lead_provider.id,
          ).merge(permitted_params["attributes"] || {})
        end
      end
    end
  end
end
