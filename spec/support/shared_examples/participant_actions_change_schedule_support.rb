# frozen_string_literal: true

RSpec.shared_examples "JSON Participant Change schedule endpoint" do
  let(:cohort) { Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021) }

  describe "/api/v1/participants/ID/change-schedule" do
    let(:parsed_response) { JSON.parse(response.body) }

    before do
      create(:schedule, schedule_identifier: "ecf-january-standard-2021", name: "ECF January standard 2021", cohort:)
    end

    it "changes participant schedule" do
      put "/api/v1/participants/#{early_career_teacher_profile.user.id}/change-schedule", params: {
        data: {
          attributes: {
            course_identifier: "ecf-induction",
            schedule_identifier: "ecf-january-standard-2021",
            cohort: "2021",
          },
        },
      }

      expect(response).to be_successful
      expect(parsed_response.dig("data", "attributes", "schedule_identifier")).to eql("ecf-january-standard-2021")
    end
  end

  describe "/api/v1/participants/ID/change-schedule with cohort" do
    let(:parsed_response) { JSON.parse(response.body) }

    let!(:schedule) { create(:schedule, schedule_identifier: "schedule", name: "schedule", cohort:) }
    let!(:new_schedule) { create(:schedule, schedule_identifier: "new-schedule", name: "new schedule", cohort:) }

    it "changes participant schedule" do
      expect {
        put "/api/v1/participants/#{early_career_teacher_profile.user.id}/change-schedule", params: {
          data: {
            attributes: {
              course_identifier: "ecf-induction",
              schedule_identifier: new_schedule.schedule_identifier,
              cohort: "2021",
            },
          },
        }
      }.to change { early_career_teacher_profile.reload.schedule }.to(new_schedule)

      expect(response).to be_successful
      expect(parsed_response.dig("data", "attributes", "schedule_identifier")).to eql(new_schedule.schedule_identifier)
    end
  end

  describe "/api/v1/participants/ID/change-schedule with declarations from payments frozen cohort" do
    let(:parsed_response) { JSON.parse(response.body) }

    let!(:schedule) { early_career_teacher_profile.schedule }
    let(:new_cohort) { Cohort.active_registration_cohort }
    let(:new_schedule) { create(:ecf_schedule, schedule_identifier: "new-schedule", name: "new schedule", cohort: new_cohort) }

    before do
      cohort.freeze_payments!
      create(:partnership,
             school: early_career_teacher_profile.school,
             cohort: new_cohort,
             lead_provider: early_career_teacher_profile.lead_provider)
      create(:ect_participant_declaration,
             participant_profile: early_career_teacher_profile,
             user: early_career_teacher_profile.user,
             cohort:,
             state: :paid,
             cpd_lead_provider: early_career_teacher_profile.lead_provider.cpd_lead_provider)
      induction_programme = early_career_teacher_profile.latest_induction_record.induction_programme
      create(:school_cohort, school: early_career_teacher_profile.school, cohort: new_cohort, default_induction_programme: induction_programme)
    end

    it "changes participant schedule" do
      expect {
        put "/api/v1/participants/#{early_career_teacher_profile.user.id}/change-schedule", params: {
          data: {
            attributes: {
              course_identifier: "ecf-induction",
              schedule_identifier: new_schedule.schedule_identifier,
              cohort: new_cohort.start_year,
            },
          },
        }
      }.to change { early_career_teacher_profile.reload.cohort_changed_after_payments_frozen }.to(true)
      .and change { early_career_teacher_profile.reload.schedule }.to(new_schedule)

      expect(response).to be_successful
      expect(parsed_response.dig("data", "attributes", "schedule_identifier")).to eql(new_schedule.schedule_identifier)
    end

    context "when they have changed schedule to a future cohort" do
      before do
        put "/api/v1/participants/#{early_career_teacher_profile.user.id}/change-schedule", params: {
          data: {
            attributes: {
              course_identifier: "ecf-induction",
              schedule_identifier: new_schedule.schedule_identifier,
              cohort: new_cohort.start_year,
            },
          },
        }
      end

      it "allows them to change back to their original cohort" do
        expect {
          put "/api/v1/participants/#{early_career_teacher_profile.user.id}/change-schedule", params: {
            data: {
              attributes: {
                course_identifier: "ecf-induction",
                schedule_identifier: schedule.schedule_identifier,
                cohort: cohort.start_year,
              },
            },
          }
        }.to change { early_career_teacher_profile.reload.cohort_changed_after_payments_frozen }.to(false)
        .and change { early_career_teacher_profile.reload.schedule }.to(schedule)
      end
    end
  end

  describe "/api/v1/participants/ecf/ID/change-schedule" do
    let(:parsed_response) { JSON.parse(response.body) }

    before do
      create(:schedule, schedule_identifier: "ecf-january-standard-2021", name: "ECF January standard 2021", cohort:)
    end

    it "changes participant schedule" do
      put "/api/v1/participants/ecf/#{early_career_teacher_profile.user.id}/change-schedule", params: {
        data: {
          attributes: {
            course_identifier: "ecf-induction",
            schedule_identifier: "ecf-january-standard-2021",
            cohort: "2021",
          },
        },
      }

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
      produces "application/json"

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
