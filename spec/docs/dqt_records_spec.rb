# frozen_string_literal: true

require "swagger_helper"

describe "API", type: :request, swagger_doc: "v1/api_spec.json" do
  let(:token) { NpqRegistrationApiToken.create_with_random_token! }
  let(:bearer_token) { "Bearer #{token}" }
  let(:Authorization) { bearer_token }
  let(:teacher_reference_number) { "1234567" }

  before do
    stub_request(:get, "http://api/qualified-teachers/qualified-teaching-status?ni&trn=1234567")
      .to_return(status: 200, body: response_body, headers: {})

    stub_request(:get, "http://api/qualified-teachers/qualified-teaching-status?ni&trn=123456")
      .to_return(status: 404, body: "", headers: {})
  end

  let(:response_body) do
    {
      data: [
        {
          trn: "1234567",
          name: "John Doe",
          doB: "1960-12-13",
          niNumber: "AB123456C",
          qtsAwardDate: "1990-12-13",
          activeAlert: false,
        },
      ],
    }.to_json
  end

  path "/api/v1/dqt-records/{teacher_reference_number}" do
    get "Returns a specific DQT record" do
      operationId :api_v1_dqt_record_show
      tags "dqt_record"
      produces "application/vnd.api+json"
      security [bearerAuth: []]

      parameter name: :teacher_reference_number,
                in: :path,
                type: :string,
                required: true,
                description: "Teacher Reference Number",
                example: "1234567"

      response "200", "A DQT record" do
        schema type: :object,
               required: %w[data],
               properties: {
                 data: {
                   type: :object,
                   required: %w[id type attributes],
                   properties: {
                     id: { type: :string },
                     type: { type: :string },
                     attributes: {
                       type: :object,
                       required: %w[teacher_reference_number full_name date_of_birth national_insurance_number qts_date active_alert],
                       properties: {
                         teacher_reference_number: { type: :string },
                         full_name: { type: :string },
                         date_of_birth: { type: :string },
                         national_insurance_number: { type: :string },
                         qts_date: { type: :string },
                         active_alert: { type: :boolean },
                       },
                     },
                   },
                 },
               }

        run_test! do |response|
          parsed_body = JSON.parse(response.body)

          expect(parsed_body).to eql(
            {
              "data" => {
                "id" => "1234567",
                "type" => "dqt_record",
                "attributes" => {
                  "teacher_reference_number" => "1234567",
                  "full_name" => "John Doe",
                  "date_of_birth" => "1960-12-13",
                  "national_insurance_number" => "AB123456C",
                  "qts_date" => "1990-12-13",
                  "active_alert" => false,
                },
              },
            },
          )
        end
      end

      response "404", "No DQT record found for Teacher Reference Number" do
        let(:teacher_reference_number) { "123456" }

        run_test!
      end

      response "401", "Unauthorized" do
        let(:Authorization) { "Bearer invalid" }

        run_test!
      end
    end
  end
end
