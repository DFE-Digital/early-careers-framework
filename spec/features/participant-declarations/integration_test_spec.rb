# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Integration Test", type: :feature do
  background(:all) do
    setup
  end

  scenario "ECT details sent to provider, declaration sent using same unique ID, no errors in declaration" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id
    then_the_declaration_made_is_valid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_was_successful
  end

private

  def given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    ect_profile = create(:early_career_teacher_profile)
    delivery_partner = create(:delivery_partner)
    create(:partnership,
           school: ect_profile.school,
           lead_provider: @cpd_lead_provider.lead_provider,
           cohort: ect_profile.cohort,
           delivery_partner: delivery_partner)

    @participant_id = ect_profile.user.id
  end

  def when_the_participant_details_are_passed_to_the_lead_provider
    @session.get("/api/v1/participants",
                 headers: { "Authorization": "Bearer #{@token}" })
    participants = JSON.parse(@session.response.body).dig("data").map { |a| a["id"] }
    expect(participants.first).to eq(@participant_id)
  end

  def and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id
    @params = common_params(@participant_id, "ecf-induction")
  end

  def then_the_declaration_made_is_valid
    expect {
      @response = @session.post("/api/v1/participant-declarations",
                                params: @params,
                                headers: { "Authorization": "Bearer #{@token}" })
    }.to change(ParticipantDeclaration, :count).by(1)
  end

  def and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_was_successful
    expect(@response).to eq(200)
  end

  # helper methods

  def setup
    lead_provider = create(:lead_provider)
    @cpd_lead_provider = create(:cpd_lead_provider, lead_provider: lead_provider)
    @token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: @cpd_lead_provider)
    @session = ActionDispatch::Integration::Session.new(Rails.application)

    @params = common_params(@participant_id, "ecf-induction")
  end

  #------------

  scenario "ECT details sent to provider, declaration sent using same unique ID, errors exist in declaration" do
    given_there_is_a_token
    and_there_is_a_participant
    and_there_is_wrong_declaration_params(@participant_id)

    response = @session.post("/api/v1/participant-declarations", params: @params, headers: { "Authorization": "Bearer #{@token}" })
    expect(response).to eq(422)
  end

  scenario "ECT details sent to provider, declaration sent using different unique ID, errors exist in declaration" do
    given_there_is_a_token
    and_there_is_a_participant
    and_there_is_participant_declaration_params("111-111-111-111")

    response = @session.post("/api/v1/participant-declarations", params: @params, headers: { "Authorization": "Bearer #{@token}" })
    expect(response).to eq(422)
  end

  scenario "Mentor details sent to provider, declaration sent using same unique ID, no errors in declaration" do
    given_there_is_a_token
    and_there_is_a_mentor
    and_there_is_mentor_declaration_params(@mentor_id)

    response = @session.post("/api/v1/participant-declarations", params: @params, headers: { "Authorization": "Bearer #{@token}" })
    expect(response).to eq(200)
  end

  scenario "Mentor details sent to provider, declaration sent using same unique ID, errors exist in declaration" do
    given_there_is_a_token
    and_there_is_a_mentor
    and_there_is_wrong_declaration_params(@mentor_id)

    response = @session.post("/api/v1/participant-declarations", params: @params, headers: { "Authorization": "Bearer #{@token}" })
    expect(response).to eq(422)
  end

  scenario "Mentor details sent to provider, declaration sent using different unique ID, errors exist in declaration" do
    given_there_is_a_token
    and_there_is_a_mentor
    and_there_is_mentor_declaration_params("111-111-111-111")

    response = @session.post("/api/v1/participant-declarations", params: @params, headers: { "Authorization": "Bearer #{@token}" })
    expect(response).to eq(422)
  end

  scenario "NPQ participant details sent to provider, declaration sent using same unique ID, no errors in declaration" do
    given_there_is_a_token
    and_there_is_a_npq_profile
    and_there_is_npq_declaration_params(@npq_profile_id)

    response = @session.post("/api/v1/participant-declarations", params: @params, headers: { "Authorization": "Bearer #{@token}" })
    expect(response).to eq(200)
  end

  scenario "NPQ participant details sent to provider, declaration sent using same unique ID, errors exist in declaration" do
    given_there_is_a_token
    and_there_is_a_npq_profile
    and_there_is_wrong_declaration_params(@npq_profile_id)

    response = @session.post("/api/v1/participant-declarations", params: @params, headers: { "Authorization": "Bearer #{@token}" })
    expect(response).to eq(422)
  end

  scenario "NPQ participant details sent to provider, declaration sent using different unique ID, errors exist in declaration" do
    given_there_is_a_token
    and_there_is_a_npq_profile
    and_there_is_npq_declaration_params("111-111-111-111")

    response = @session.post("/api/v1/participant-declarations", params: @params, headers: { "Authorization": "Bearer #{@token}" })
    expect(response).to eq(422)
  end

private

  def given_there_is_a_token
    lead_provider = create(:lead_provider)
    @cpd_lead_provider = create(:cpd_lead_provider, lead_provider: lead_provider)
    @token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: @cpd_lead_provider)
    @session = ActionDispatch::Integration::Session.new(Rails.application)
  end

  def and_there_is_participant_declaration_params(participant_id)
    @params = common_params(participant_id, "ecf-induction")
  end

  def and_there_is_mentor_declaration_params(mentor_id)
    @params = common_params(mentor_id, "ecf-mentor")
  end

  def and_there_is_npq_declaration_params(npq_profile_id)
    @params = common_params(npq_profile_id, "npq-leading-teaching")
  end

  def and_there_is_wrong_declaration_params(participant_id)
    @params = common_params(participant_id, "ecf-induction")
    @params["data"]["attributes"].reject! { |a| a["participant_id"] }
  end

  def common_params(participant_id, course_identifier)
    JSON.parse(<<~DATA)
      {
      "data":{
        "type":"participant-declaration",
        "attributes": {
           "participant_id": "#{participant_id}",
           "declaration_type": "started",
           "declaration_date": "2021-01-01T01:01:01.000Z",
      		 "course_identifier": "#{course_identifier}"
         }
       }
      }
    DATA
  end

  def and_there_is_a_participant
    @participant_id = create(:early_career_teacher_profile).user.id
  end

  def and_there_is_a_mentor
    @mentor_id = create(:mentor_profile).user.id
  end

  def and_there_is_a_npq_profile
    npq_lead_provider = create(:npq_lead_provider, cpd_lead_provider: @cpd_lead_provider)
    npq_course = create(:npq_course, identifier: "npq-leading-teaching")
    @npq_profile_id = create(:npq_validation_data,
                             npq_lead_provider: npq_lead_provider,
                             npq_course: npq_course).user.id
  end
end
