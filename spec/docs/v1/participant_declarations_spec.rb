# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Participant Declarations", :with_default_schedules, type: :request, swagger_doc: "v1/api_spec.json" do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider) }
  let(:ect_profile)       { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }
  let(:user)              { ect_profile.teacher_profile.user }
  let(:token)             { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:bearer_token)      { "Bearer #{token}" }
  let(:Authorization)     { bearer_token }
  let(:declaration_date)  { ect_profile.schedule.milestones.first.start_date }

  path "/api/v1/participant-declarations" do
    post "Declare a participant has reached a milestone. Idempotent endpoint - submitting exact copy of a request will return the same response body as submitting it the first time." do
      operationId :participant_declarations
      tags "Participant declarations"
      consumes "application/json"
      security [bearerAuth: []]

      parameter name: :params,
                in: :body,
                schema: {
                  "$ref": "#/components/schemas/ParticipantDeclaration",
                }

      response 200, "Successful" do
        let(:attributes) do
          {
            participant_id: user.id,
            declaration_date: declaration_date.rfc3339,
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
              "attributes": {},
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
                example: CGI.unescape({
                  participant_id: "ab3a7848-1208-7679-942a-b4a70eed400a",
                  updated_since: "2020-11-13T11:21:55Z",
                }.to_param)

      parameter name: :page,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/Pagination",
                },
                type: :object,
                style: :deepObject,
                explode: true,
                required: false,
                example: CGI.unescape({ page: { page: 1, per_page: 5 } }.to_param),
                description: "Pagination options to navigate through the list of participant declarations."

      response "200", "A list of participant declarations" do
        schema({ "$ref": "#/components/schemas/MultipleParticipantDeclarationsResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

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

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v1/participant-declarations/{id}" do
    let(:id) do
      create(:ect_participant_declaration,
             user:,
             cpd_lead_provider:).id
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
        schema({ "$ref": "#/components/schemas/SingleParticipantDeclarationResponse" })

        run_test!
      end

      response "404", "Not found", exceptions_app: true do
        let(:id) { "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" }

        schema({ "$ref": "#/components/schemas/NotFoundResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

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
          declaration = create(:participant_declaration, user: ect_profile.user, cpd_lead_provider:, course_identifier: "ecf-induction", participant_profile: ect_profile)
          declaration.id
        end

        schema({ "$ref": "#/components/schemas/SingleParticipantDeclarationResponse" })
        run_test!
      end
    end
  end
end
