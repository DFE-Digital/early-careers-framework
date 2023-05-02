# frozen_string_literal: true

module Api
  module V3
    module ECF
      class TransfersController < Api::ApiController
        include ApiTokenAuthenticatable
        include ApiPagination
        include ApiFilter

        # Returns a list of ECF participant transfers
        # Providers can see the ECF participant transfers via this endpoint
        #
        # GET /api/v3/transfers/ecf?filter[updated_since]=2022-11-13T11:21:55Z
        #
        def index
          render json: serializer_class.new(paginate(ecf_transfers), params: { cpd_lead_provider: current_user }).serializable_hash.to_json
        end

        # Returns a specific ECF participant transfer given its ID
        # Providers can see a specific ECF participant transfer via this endpoint
        #
        # GET /api/v1/participants/ecf/:id/transfers
        #
        def show
          render json: serializer_class.new(ecf_transfer, params: { cpd_lead_provider: current_user }).serializable_hash.to_json
        end

      private

        def lead_provider
          @lead_provider ||= current_user.lead_provider
        end

        def ecf_transfers
          @ecf_transfers ||= ecf_transfers_query.users
        end

        def ecf_transfer
          @ecf_transfer ||= ecf_transfers_query.user
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
            .permit(:participant_id, filter: %i[updated_since])
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
