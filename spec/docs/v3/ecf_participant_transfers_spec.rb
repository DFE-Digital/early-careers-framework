# frozen_string_literal: true

require "swagger_helper"

describe "API", type: :request, swagger_doc: "v3/api_spec.json" do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }
  let!(:cohort) { create(:cohort, :current) }
  let!(:transfer) do
    NewSeeds::Scenarios::Participants::Transfers::FipToFipKeepingOriginalTrainingProvider
      .new(lead_provider_from: cpd_lead_provider.lead_provider)
      .build
  end

  path "/api/v3/participants/ecf/transfers" do
    get "<b>Note, this endpoint is new.</b><br/>Retrieve multiple ECF participant transfers" do
      operationId :participants
      tags "participant transfers"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ListFilter",
                },
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine participant transfers to return.",
                example: CGI.unescape({ filter: { updated_since: "2020-11-13T11:21:55Z" } }.to_param)

      parameter name: :page,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/Pagination",
                },
                style: :deepObject,
                explode: true,
                required: false,
                example: CGI.unescape({ page: { page: 1, per_page: 5 } }.to_param),
                description: "Pagination options to navigate through the list of participant transfers."

      response "200", "A list of ECF participant transfers" do
        schema({ "$ref": "#/components/schemas/MultipleECFParticipantTransferResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/participants/ecf/{id}/transfers" do
    get "<b>Note, this endpoint is new.</b><br/>Get a single participant's transfers" do
      operationId :participant_transfers
      tags "participant transfers"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the ECF participant.",
                schema: {
                  type: "string",
                }

      response "200", "A single participant's transfers" do
        let(:id) { transfer.preferred_identity.user.id }

        schema({ "$ref": "#/components/schemas/ECFParticipantTransferResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:id) { transfer.preferred_identity.user.id }
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end

      response "404", "Not Found", exceptions_app: true do
        let(:id) { "wrong-id" }
        schema({ "$ref": "#/components/schemas/NotFoundResponse" })

        run_test!
      end
    end
  end
end
