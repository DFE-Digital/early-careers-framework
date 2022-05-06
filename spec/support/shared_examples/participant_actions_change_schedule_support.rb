# frozen_string_literal: true

RSpec.shared_examples "JSON Participant Change schedule endpoint" do
  describe "/api/v1/participants/ID/change-schedule" do
    let(:parsed_response) { JSON.parse(response.body) }

    before do
      create(:schedule, schedule_identifier: "ecf-january-standard-2021", name: "ECF January standard 2021")
    end

    it "changes participant schedule" do
      put "/api/v1/participants/#{early_career_teacher_profile.user.id}/change-schedule", params: {
        data: {
          attributes: {
            course_identifier: "ecf-induction",
            schedule_identifier: "ecf-january-standard-2021",
          },
        },
      }

      expect(response).to be_successful
      expect(parsed_response.dig("data", "attributes", "schedule_identifier")).to eql("ecf-january-standard-2021")
    end
  end

  describe "/api/v1/participants/ID/change-schedule with cohort" do
    let(:parsed_response) { JSON.parse(response.body) }
    let(:cohort_2022) { Cohort.next || create(:cohort, :next) }

    let!(:schedule_2021) { create(:schedule, schedule_identifier: "ecf", name: "ECF 2021") }
    let(:schedule_2022) { create(:schedule, schedule_identifier: "ecf", name: "ECF 2022", cohort: cohort_2022) }

    before do
      allow(FeatureFlag).to receive(:active?).with(:multiple_cohorts).and_return(true)
      schedule_2022
    end

    it "changes participant schedule" do
      expect {
        put "/api/v1/participants/#{early_career_teacher_profile.user.id}/change-schedule", params: {
          data: {
            attributes: {
              course_identifier: "ecf-induction",
              schedule_identifier: schedule_2022.schedule_identifier,
              cohort: "2022",
            },
          },
        }
      }.to change { early_career_teacher_profile.reload.schedule }.to(schedule_2022)

      expect(response).to be_successful
      expect(parsed_response.dig("data", "attributes", "schedule_identifier")).to eql(schedule_2022.schedule_identifier)
    end
  end

  describe "/api/v1/participants/ecf/ID/change-schedule" do
    let(:parsed_response) { JSON.parse(response.body) }

    before do
      create(:schedule, schedule_identifier: "ecf-january-standard-2021", name: "ECF January standard 2021")
    end

    it "changes participant schedule" do
      put "/api/v1/participants/ecf/#{early_career_teacher_profile.user.id}/change-schedule", params: { data: { attributes: { course_identifier: "ecf-induction", schedule_identifier: "ecf-january-standard-2021" } } }

      expect(response).to be_successful
      expect(parsed_response.dig("data", "attributes", "schedule_identifier")).to eql("ecf-january-standard-2021")
    end
  end
end

RSpec.shared_examples "JSON Participant Change schedule documentation" do |url, request_schema_ref, response_schema_ref, tag|
  humanised_description = TAG_TO_HUMANISED_DESCRIPTION[tag]
  operation_id = TAG_TO_OPERATION_ID[tag]

  path url do
    put "Notify that an #{humanised_description} is changing training schedule" do
      operationId operation_id
      tags tag
      security [bearerAuth: []]
      consumes "application/json"

      request_body content: {
        "application/json": {
          "schema": {
            "$ref": request_schema_ref,
          },
        },
      }

      parameter name: :id,
                in: :path,
                type: :string,
                required: true,
                example: "28c461ee-ffc0-4e56-96bd-788579a0ed75",
                description: "The ID of the participant"

      parameter name: :params,
                in: :body,
                type: :object,
                style: :deepObject,
                required: true,
                schema: {
                  "$ref": request_schema_ref,
                }

      response "200", "The #{humanised_description} changing schedule" do
        let(:id) { participant.user.id }
        let(:params) do
          {
            "data": {
              "type": "participant",
              "attributes": attributes,
            },
          }
        end

        schema({ "$ref": response_schema_ref })
        run_test!
      end
    end
  end
end
