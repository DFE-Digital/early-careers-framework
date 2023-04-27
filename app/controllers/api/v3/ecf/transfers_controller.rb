# frozen_string_literal: true

module Api
  module V3
    module ECF
      class TransfersController < Api::ApiController
        include ApiTokenAuthenticatable
        include ApiPagination
        include ApiFilter
        include ApiOrderable

        # Returns a list of participant transfers
        # Providers can see the participant transfers via this endpoint
        #
        # GET /api/v3/transfers/ecf?filter[updated_since]=2022-11-13T11:21:55Z
        #
        def index
          render json: serializer_class.new(paginate(ecf_transfers), params: { cpd_lead_provider: current_user }).serializable_hash.to_json
        end

      private

        def lead_provider
          @lead_provider ||= current_user.lead_provider
        end

        def ecf_transfers
          @ecf_transfers ||= ecf_transfers_query.users
        end

        def ecf_transfers_query
          TransfersQuery.new(
            lead_provider:,
            params: ecf_transfer_params,
          )
        end

        def ecf_transfer_params
          params
            .with_defaults({ filter: { updated_since: "" } })
            .permit(:id, filter: %i[updated_since])
        end

        def access_scope
          LeadProviderApiToken.joins(cpd_lead_provider: [:lead_provider])
        end

        def serializer_class
          TransferSerializer
        end
      end
    end
  end
end
