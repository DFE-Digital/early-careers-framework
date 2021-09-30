# frozen_string_literal: true

require "swagger_helper"
require_relative "../shared/context/service_record_declaration_params"
require_relative "../shared/context/lead_provider_profiles_and_courses"

RSpec.describe "Participant Declarations", type: :request, swagger_doc: "v1/api_spec.json" do
  include_context "lead provider profiles and courses"
  include_context "service record declaration params"

  let(:user) { ect_profile.user }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: cpd_lead_provider) }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }

  before do
    travel_to ect_profile.schedule.milestones.first.start_date + 2.days
  end

  path "/api/v1/participant-declarations" do
    post "Declare a participant has reached a milestone. Idempotent endpoint - submitting exact copy of a request will return the same response body as submitting it the first time." do
      operationId :participant_declarations
      tags "Participant declarations"
      consumes "application/json"
      security [bearerAuth: []]

      request_body content: {
        "application/json": {
          "schema": {
            "$ref": "#/components/schemas/ParticipantDeclaration",
          },
        },
      }

      parameter name: :params,
                in: :body,
                schema: {
                  "$ref": "#/components/schemas/ParticipantDeclaration",
                }

      response 200, "Successful" do
        let(:attributes) do
          {
            participant_id: ect_profile.user.id,
            declaration_date: ect_declaration_date.rfc3339,
            declaration_type: "started",
            course_identifier: "ecf-induction",
          }
        end

        let(:params) do
          {
            "data": {
              "type": "participant-declaration",
              "attributes": attributes,
            },
          }
        end

        schema({ "$ref": "#/components/schemas/SingleParticipantDeclarationResponse" })
        run_test!
      end

      response "422", "Bad or Missing parameter" do
        let(:user) { build(:user, :early_career_teacher) }

        let(:params) do
          {
            "data": {
              "type": "participant-declaration",
              "attributes": {
              },
            },
          }
        end

        schema({ "$ref": "#/components/schemas/ErrorResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end

      response "400", "Bad Request" do
        schema({ "$ref": "#/components/schemas/BadRequestResponse" })

        run_test!
      end
    end
  end

  path "/api/v1/participant-declarations" do
    get "List all participant declarations" do
      operationId :participant_declarations
      tags "participants declarations"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ListFilterDeclarations",
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine participant declarations to return.",
                example: {
                  participant_id: "ab3a7848-1208-7679-942a-b4a70eed400a",
                  updated_since: "2020-11-13T11:21:55Z",
                }

      parameter name: :page,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/Pagination",
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                example: { page: 1, per_page: 5 },
                description: "Pagination options to navigate through the list of participant declarations."

      response "200", "A list of participant declarations" do
        schema({ "$ref": "#/components/schemas/MultipleParticipantDeclarationsResponse" }, content_type: "application/vnd.api+json")

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" }, content_type: "application/vnd.api+json")

        run_test!
      end
    end
  end

  path "/api/v1/participant-declarations.csv" do
    get "Retrieve all participant declarations in CSV format" do
      operationId :ecf_participant_declarations_csv
      tags "Participant declarations"
      security [bearerAuth: []]

      response "200", "A CSV file of participant declarations" do
        schema({ "$ref": "#/components/schemas/MultipleParticipantDeclarationsCsvResponse" }, content_type: "text/csv")

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" }, content_type: "application/vnd.api+json")

        run_test!
      end
    end
  end

  path "/api/v1/participant-declarations/{id}" do
    let(:id) do
      create(:participant_declaration,
             user: user,
             cpd_lead_provider: cpd_lead_provider,
             course_identifier: "ecf-induction").id
    end

    get "Get single participant declaration" do
      operationId :participant_declarations
      tags "participants declaration"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: "9ed4612b-f8bd-44d9-b296-38ab103fadd2",
                description: "The ID of the participant declaration ID"

      response "200", "A single participant declaration" do
        schema({ "$ref": "#/components/schemas/SingleParticipantDeclarationResponse" }, content_type: "application/vnd.api+json")

        run_test!
      end

      response "404", "Not found" do
        let(:id) { "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" }

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" }, content_type: "application/vnd.api+json")

        run_test!
      end
    end
  end

  path "/api/v1/participant-declarations/{id}/void" do
    put "Void a declaration - it will not be soft-deleted" do
      operationId :participant_declarations
      tags "Participant declarations"
      consumes "application/json"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the declaration to void"

      response 200, "Successful" do
        let(:id) do
          declaration = create(:participant_declaration, user: ect_profile.user, cpd_lead_provider: cpd_lead_provider, course_identifier: "ecf-induction")
          create(:profile_declaration, participant_declaration: declaration, participant_profile: ect_profile)
          declaration.id
        end

        schema({ "$ref": "#/components/schemas/SingleParticipantDeclarationResponse" })
        run_test!
      end
    end
  end
end
