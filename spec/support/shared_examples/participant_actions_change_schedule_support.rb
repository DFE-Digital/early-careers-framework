# frozen_string_literal: true

RSpec.shared_examples "a participant change schedule action service" do
  it_behaves_like "a participant action service"

  let!(:january_schedule) do
    create(
      :schedule,
      schedule_identifier: "ecf-january-standard-2021",
      identifier_alias: "ecf-january-standard-2021-alias",
      name: "ECF January standard schedule 2021",
    )
  end

  let(:expected_schedule) { january_schedule }

  it "changes the schedule on user's profile" do
    expect {
      described_class.new(params: given_params).call
      user_profile.reload
    }.to change(user_profile, :schedule).to(expected_schedule)
  end

  let(:schedule_identifier_alias) { "ecf-january-standard-2021-alias" }

  it "succeeds when given alias of schedule identifier" do
    params = given_params.merge({ schedule_identifier: schedule_identifier_alias })

    expect {
      described_class.new(params: params).call
      user_profile.reload
    }.to change(user_profile, :schedule).to(expected_schedule)
  end

  it "fails when the schedule is invalid" do
    params = given_params.merge({ schedule_identifier: "wibble" })
    expect { described_class.new(params: params).call }.to raise_error(ActionController::ParameterMissing)
  end

  it "fails when the participant is withdrawn" do
    ParticipantProfileState.create!(participant_profile: user_profile, state: "withdrawn")
    expect { described_class.new(params: given_params).call }.to raise_error(ActionController::ParameterMissing)
  end

  it "creates a schedule on profile" do
    expect { described_class.new(params: participant_params).call }.to change { ParticipantProfileSchedule.count }.by(1)
    expect(user_profile.participant_profile_schedules.first.schedule.schedule_identifier).to eq(expected_schedule.schedule_identifier)
  end

  context "when a pending declaration exists" do
    let!(:declaration) do
      start_date = user_profile.schedule.milestones.first.start_date
      create(:participant_declaration, declaration_date: start_date + 1.day, course_identifier: "ecf-induction", declaration_type: "started", cpd_lead_provider: cpd_lead_provider, participant_profile: user_profile)
    end

    it "fails when it would invalidate a valid declaration" do
      expected_schedule.milestones.each { |milestone| milestone.update!(start_date: milestone.start_date + 6.months, milestone_date: milestone.milestone_date + 6.months) }

      expect { described_class.new(params: given_params).call }.to raise_error(ActionController::ParameterMissing)
    end

    it "ignores voided declarations when changing the schedule" do
      declaration.voided!
      january_schedule.milestones.each { |milestone| milestone.update!(start_date: milestone.start_date + 6.months, milestone_date: milestone.milestone_date + 6.months) }

      described_class.new(params: given_params).call
      expect(user_profile.reload.schedule.schedule_identifier).to eq(expected_schedule.schedule_identifier)
    end
  end
end

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
    let(:cohort_2022) { create(:cohort, start_year: "2022") }

    let!(:schedule_2021) { create(:schedule, schedule_identifier: "ecf", name: "ECF 2021") }
    let!(:schedule_2022) { create(:schedule, schedule_identifier: "ecf", name: "ECF 2022", cohort: cohort_2022) }

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
