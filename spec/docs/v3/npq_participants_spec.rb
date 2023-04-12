# frozen_string_literal: true

require "swagger_helper"

describe "API", :with_default_schedules, type: :request, swagger_doc: "v3/api_spec.json", api_v3: true do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, npq_lead_provider:) }
  let(:npq_lead_provider) { create(:npq_lead_provider) }
  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider:) }
  let(:Authorization) { "Bearer #{token}" }
  let!(:npq_application) { create(:npq_application, :accepted, npq_lead_provider:) }

  path "/api/v3/participants/npq" do
    get "<b>Note, this endpoint includes updated specifications.</b><br/>Retrieve multiple NPQ participants" do
      operationId :npq_participants
      tags "NPQ participants"
      security [bearerAuth: []]

      parameter name: :filter,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/ListFilter",
                },
                style: :deepObject,
                explode: true,
                required: false,
                description: "Refine NPQ participants to return.",
                example: CGI.unescape({ updated_since: "2020-11-13T11:21:55Z" }.to_param)

      parameter name: :page,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/Pagination",
                },
                style: :deepObject,
                explode: true,
                required: false,
                example: CGI.unescape({ page: { page: 1, per_page: 5 } }.to_param),
                description: "Pagination options to navigate through the list of NPQ participants."

      parameter name: :sort,
                in: :query,
                schema: {
                  "$ref": "#/components/schemas/NPQParticipantsSort",
                },
                style: :form,
                explode: false,
                required: false,
                description: "Sort NPQ participants being returned.",
                example: "sort=-updated_at"

      response "200", "A list of NPQ participants" do
        schema({ "$ref": "#/components/schemas/MultipleNPQParticipantsResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/participants/npq/{id}" do
    get "<b>Note, this endpoint includes updated specifications.</b><br/>Get a single NPQ participant" do
      operationId :npq_participant
      tags "NPQ participants"
      security [bearerAuth: []]

      parameter name: :id,
                in: :path,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the NPQ participant.",
                schema: {
                  type: "string",
                }

      response "200", "A single NPQ participant" do
        let(:id) { npq_application.participant_identity.external_identifier }

        schema({ "$ref": "#/components/schemas/NPQParticipantResponse" })

        run_test!
      end

      response "401", "Unauthorized" do
        let(:id) { npq_application.participant_identity.external_identifier }
        let(:Authorization) { "Bearer invalid" }

        schema({ "$ref": "#/components/schemas/UnauthorisedResponse" })

        run_test!
      end

      response "404", "Not Found" do
        schema({ "$ref": "#/components/schemas/NotFoundResponse" })

        run_test!
      end
    end
  end

  it_behaves_like "JSON Participant Change schedule documentation",
                  "/api/v3/participants/npq/{id}/change-schedule",
                  "#/components/schemas/NPQParticipantChangeScheduleRequest",
                  "#/components/schemas/NPQParticipantResponse",
                  "NPQ Participant",
                  :with_default_schedules do
    let(:participant) { npq_application }
    let(:profile)     { npq_application.profile }
    let(:new_schedule) do
      if Finance::Schedule::NPQLeadership::IDENTIFIERS.include?(profile.npq_course.identifier)
        create(:npq_leadership_schedule)
      elsif Finance::Schedule::NPQSpecialist::IDENTIFIERS.include?(profile.npq_course.identifier)
        create(:npq_specialist_schedule)
      else
        create(:npq_aso_schedule)
      end
    end

    let(:attributes) do
      {
        schedule_identifier: new_schedule.schedule_identifier,
        course_identifier: npq_application.npq_course.identifier,
        cohort: new_schedule.cohort.start_year,
      }
    end
  end

  it_behaves_like "JSON Participant Deferral documentation",
                  "/api/v3/participants/npq/{id}/defer",
                  "#/components/schemas/NPQParticipantDeferRequest",
                  "#/components/schemas/NPQParticipantResponse",
                  "NPQ Participant" do
    let(:participant) { npq_application }
    let(:attributes) do
      {
        reason: ParticipantProfile::DEFERRAL_REASONS.sample,
        course_identifier: npq_application.npq_course.identifier,
      }
    end
  end

  it_behaves_like "JSON Participant resume documentation",
                  "/api/v3/participants/npq/{id}/resume",
                  "#/components/schemas/NPQParticipantResumeRequest",
                  "#/components/schemas/NPQParticipantResponse",
                  "NPQ Participant" do
    let(:participant) { npq_application }
    let(:attributes) { { course_identifier: npq_application.npq_course.identifier } }
    before do
      DeferParticipant.new(
        participant_id: npq_application.participant_identity.external_identifier,
        reason: ParticipantProfile::DEFERRAL_REASONS.sample,
        course_identifier: npq_application.npq_course.identifier,
        cpd_lead_provider:,
      ).call
    end
  end

  path "/api/v3/participants/npq/{id}/withdraw" do
    put "<b>Note, this endpoint includes updated specifications.</b><br/>Withdrawn a participant from a course" do
      operationId :npq_participants
      tags "NPQ Participant"
      security [bearerAuth: []]
      consumes "application/json"

      parameter name: :id,
                in: :path,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the participant to withdraw",
                schema: {
                  type: "string",
                }

      parameter name: :params,
                in: :body,
                style: :deepObject,
                required: true,
                schema: {
                  "$ref": "#/components/schemas/NPQParticipantWithdrawRequest",
                }

      response "200", "The NPQ participant being withdrawn" do
        let(:id) { npq_application.participant_identity.external_identifier }
        let(:attributes) do
          {
            reason: ParticipantProfile::NPQ::WITHDRAW_REASONS.sample,
            course_identifier: npq_application.npq_course.identifier,
          }
        end

        let(:params) do
          {
            "data": {
              "type": "participant",
              "attributes": attributes,
            },
          }
        end

        before do
          participant_profile = npq_application.profile
          user = npq_application.user
          course_identifier = npq_application.npq_course.identifier

          create(:npq_participant_declaration, participant_profile:, course_identifier:, user:)
        end

        schema({ "$ref": "#/components/schemas/NPQParticipantResponse" })

        after do |example|
          content = example.metadata[:response][:content] || {}

          example_spec = {
            "application/json" => {
              examples: {
                success: {
                  value: JSON.parse({
                    data: {
                      id: "db3a7848-7308-4879-942a-c4a70ced400a",
                      type: "participant",
                      attributes: {
                        "full_name": "Isabelle MacDonald",
                        "teacher_reference_number": "1234567",
                        "npq_enrolments": [
                          {
                            "email": "isabelle.macdonald2@some-school.example.com",
                            "course_identifier": "npq-senior-leadership",
                            "schedule_identifier": "npq-leadership-autumn",
                            "cohort": "2021",
                            "npq_application_id": "db3a7848-7308-4879-942a-c4a70ced400a",
                            "eligible_for_funding": true,
                            "training_status": "withdrawn",
                            "school_urn": "123456",
                            "targeted_delivery_funding_eligibility": true,
                            "withdrawal": {
                              reason: "insufficient-capacity",
                              date: "2022-12-09T16:07:38Z",
                            },
                            "created_at": "2021-05-31T02:22:32.000Z",
                          },
                        ],
                        "updated_at": "2021-05-31T02:22:32.000Z",
                      },
                    },
                  }.to_json, symbolize_names: true),
                },
              },
            },
          }

          example.metadata[:response][:content] = content.deep_merge(example_spec)
        end

        run_test!
      end

      response "422", "Unprocessable entity" do
        let(:id) { npq_application.participant_identity.external_identifier }
        let(:attributes) do
          {
            reason: ParticipantProfile::NPQ::WITHDRAW_REASONS.sample,
            course_identifier: "bogus-course-identifier",
          }
        end

        let(:params) do
          {
            "data": {
              "type": "participant",
              "attributes": attributes,
            },
          }
        end

        schema({ "$ref": "#/components/schemas/ErrorResponse" })

        run_test!
      end
    end
  end

  path "/api/v3/participants/npq/{id}/defer" do
    put "<b>Note, this endpoint includes updated specifications.</b><br/>Notify that an NPQ participant is taking a break from their course" do
      operationId :npq_participants
      tags "NPQ Participant"
      security [bearerAuth: []]
      consumes "application/json"

      parameter name: :id,
                in: :path,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the participant to defer",
                schema: {
                  type: "string",
                }

      parameter name: :params,
                in: :body,
                style: :deepObject,
                required: true,
                schema: {
                  "$ref": "#/components/schemas/NPQParticipantDeferRequest",
                }

      response "200", "The NPQ participant being deferred" do
        let(:id) { npq_application.participant_identity.external_identifier }
        let(:attributes) do
          {
            reason: ParticipantProfile::NPQ::DEFERRAL_REASONS.sample,
            course_identifier: npq_application.npq_course.identifier,
          }
        end

        let(:params) do
          {
            "data": {
              "type": "participant",
              "attributes": attributes,
            },
          }
        end

        before do
          participant_profile = npq_application.profile
          user = npq_application.user
          course_identifier = npq_application.npq_course.identifier

          create(:npq_participant_declaration, participant_profile:, course_identifier:, user:)
        end

        schema({ "$ref": "#/components/schemas/NPQParticipantResponse" })

        after do |example|
          content = example.metadata[:response][:content] || {}

          example_spec = {
            "application/json" => {
              examples: {
                success: {
                  value: JSON.parse({
                    data: {
                      id: "db3a7848-7308-4879-942a-c4a70ced400a",
                      type: "participant",
                      attributes: {
                        "full_name": "Isabelle MacDonald",
                        "teacher_reference_number": "1234567",
                        "npq_enrolments": [
                          {
                            "email": "isabelle.macdonald2@some-school.example.com",
                            "course_identifier": "npq-senior-leadership",
                            "schedule_identifier": "npq-leadership-autumn",
                            "cohort": "2021",
                            "npq_application_id": "db3a7848-7308-4879-942a-c4a70ced400a",
                            "eligible_for_funding": true,
                            "training_status": "deferred",
                            "school_urn": "123456",
                            "targeted_delivery_funding_eligibility": true,
                            "deferral": {
                              reason: "other",
                              date: "2022-12-09T16:07:38Z",
                            },
                            "created_at": "2021-05-31T02:22:32.000Z",
                          },
                        ],
                        "updated_at": "2021-05-31T02:22:32.000Z",
                      },
                    },
                  }.to_json, symbolize_names: true),
                },
              },
            },
          }

          example.metadata[:response][:content] = content.deep_merge(example_spec)
        end

        run_test!
      end

      response "422", "Unprocessable entity" do
        let(:id) { npq_application.participant_identity.external_identifier }
        let(:attributes) do
          {
            reason: ParticipantProfile::NPQ::DEFERRAL_REASONS.sample,
            course_identifier: "bogus-course-identifier",
          }
        end

        let(:params) do
          {
            "data": {
              "type": "participant",
              "attributes": attributes,
            },
          }
        end

        schema({ "$ref": "#/components/schemas/ErrorResponse" })

        run_test!
      end
    end
  end
end
