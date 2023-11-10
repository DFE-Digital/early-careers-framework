# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Participant outcomes", type: :request, end_to_end_scenario: true, perform_jobs: true do
  let(:declaration_date) { npq_application.profile.schedule.milestones.find_by(declaration_type: "completed").start_date }
  let!(:declaration) do
    travel_to declaration_date + 2.days do
      create(:npq_participant_declaration, :eligible, declaration_type: "completed", participant_profile: npq_application.profile, cpd_lead_provider: provider, declaration_date:)
    end
  end
  let(:provider) { create :cpd_lead_provider, :with_npq_lead_provider }
  let(:npq_application) { create :npq_application, :accepted, npq_lead_provider: provider.npq_lead_provider }

  let(:token) { LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: provider) }
  let(:date) { (declaration_date + 2.days).to_fs("Y-m-d") }
  let(:response_headers) { { "test" => "test" } }
  let(:queue_name) { :participant_outcomes }

  before do
    # Stub the qualified teachers API endpoint
    stub_request(:put, "#{Rails.application.config.qualified_teachers_api_url}/v2/npq-qualifications?trn=#{declaration.participant_profile.teacher_profile.trn}")
      .with(body: { completionDate: date, qualificationType: declaration.qualification_type }.to_json)
      .to_return(status: 204, headers: response_headers)
  end

  # Happy path
  scenario "provider creates a passed outcome for a participant with no previous recorded outcomes" do
    # Provider supplies the outcome via the API
    travel_to declaration_date + 3.days do
      post create_outcome_api_v2_npq_participants_path(participant_id: npq_application.participant_identity.external_identifier),
           headers: {
             Authorization: "Bearer #{token}",
             CONTENT_TYPE: "application/json",
           },
           params: {
             data: {
               type: "npq-outcome-confirmation",
               attributes: {
                 course_identifier: declaration.course_identifier,
                 state: "passed",
                 completion_date: date,
               },
             },
           }.to_json
    end

    expect(response).to be_ok
    parsed_response = JSON.parse(response.body)

    # Outcome data is stored correctly
    outcome = ParticipantOutcome::NPQ.find(parsed_response["data"]["id"])
    expect(outcome.completion_date).to eq(Date.parse(date))
    expect(outcome).to be_passed
    expect(outcome.sent_to_qualified_teachers_api_at).to be_nil

    # Outcome is sent to the qualified teachers API and the response is recorded correctly
    travel_to(date) do
      # TODO: This will either be triggered on demand or scheduled in future - remove if possible
      ParticipantOutcomes::BatchSendLatestOutcomesJob.perform_now

      outcome.reload
      expect(outcome.sent_to_qualified_teachers_api_at).to eq(Time.zone.now)
      expect(outcome).to be_qualified_teachers_api_request_successful
      expect(outcome.participant_outcome_api_requests.last.response_headers).to eq response_headers
    end
  end
end
