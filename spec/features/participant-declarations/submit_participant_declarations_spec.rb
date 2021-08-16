# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Submit participant declarations", type: :feature do
  background(:all) do
    setup
  end

  scenario "ECT details sent to provider, declaration sent using same unique ID, no errors in declaration" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id(@participant_id, "ecf-induction")
    then_the_declaration_made_is_valid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_was_successful
  end

  scenario "ECT details sent to provider, declaration sent using same unique ID, errors exist in declaration" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id_with_error("ecf-induction")
    then_the_declaration_made_is_invalid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
  end

  scenario "ECT details sent to provider, declaration sent using different unique ID, errors exist in declaration" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id("111-111-111-111", "ecf-induction")
    then_the_declaration_made_is_invalid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
  end

  scenario "Mentor details sent to provider, declaration sent using same unique ID, no errors in declaration" do
    given_an_ecf_mentor_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id(@mentor_id, "ecf-mentor")
    then_the_declaration_made_is_valid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_was_successful
  end

  scenario "Mentor details sent to provider, declaration sent using same unique ID, errors exist in declaration" do
    given_an_ecf_mentor_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id_with_error("ecf-mentor")
    then_the_declaration_made_is_invalid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
  end

  scenario "Mentor details sent to provider, declaration sent using different unique ID, errors exist in declaration" do
    given_an_ecf_mentor_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id("111-222-333-444", "ecf-mentor")
    then_the_declaration_made_is_invalid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
  end

  scenario "NPQ participant details sent to provider, declaration sent using same unique ID, no errors in declaration" do
    given_an_npq_participant_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id(@npq_profile_id, "npq-leading-teaching")
    then_the_declaration_made_is_valid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_was_successful
  end

  scenario "NPQ participant details sent to provider, declaration sent using same unique ID, errors exist in declaration" do
    given_an_npq_participant_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id_with_error("npq-leading-teaching")
    then_the_declaration_made_is_invalid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
  end

  scenario "NPQ participant details sent to provider, declaration sent using different unique ID, errors exist in declaration" do
    given_an_npq_participant_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id("111-222-333-444", "npq-leading-teaching")
    then_the_declaration_made_is_invalid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
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

  def given_an_ecf_mentor_has_been_entered_onto_the_dfe_service
    @mentor_id = create(:mentor_profile).user.id
  end

  def given_an_npq_participant_has_been_entered_onto_the_dfe_service
    npq_lead_provider = create(:npq_lead_provider, cpd_lead_provider: @cpd_lead_provider)
    npq_course = create(:npq_course, identifier: "npq-leading-teaching")
    @npq_profile_id = create(:npq_validation_data,
                             npq_lead_provider: npq_lead_provider,
                             npq_course: npq_course).user.id
  end

  def when_the_participant_details_are_passed_to_the_lead_provider
    @session.get("/api/v1/participants",
                 headers: { "Authorization": "Bearer #{@token}" })
    participants = JSON.parse(@session.response.body).dig("data").map { |participant| participant["id"] }
    expect(participants.first).to eq(@participant_id)
  end

  def and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id(participant_id, course_identifier)
    params = common_params(participant_id, course_identifier)
    submit_request(params)
  end

  def and_the_lead_provider_submits_a_declaration_for_the_participant_using_the_same_unique_id_with_error(course_identifier)
    params = common_params("", course_identifier)
    params["data"]["attributes"].reject! { |a| a["participant_id"] }
    submit_request(params)
  end

  def then_the_declaration_made_is_valid
    expect(ParticipantDeclaration.find(@response["id"])).to be_present
  end

  def then_the_declaration_made_is_invalid
    expect(@response["bad_or_missing_parameters"]).not_to be_empty
  end

  def and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_was_successful
    expect(@response_http_code).to eq(200)
  end

  def and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
    expect(@response_http_code).to eq(422)
  end

  # helper methods

  def setup
    lead_provider = create(:lead_provider)
    @cpd_lead_provider = create(:cpd_lead_provider, lead_provider: lead_provider)
    @token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: @cpd_lead_provider)
    @session = ActionDispatch::Integration::Session.new(Rails.application)

    @params = common_params(@participant_id, "ecf-induction")
  end

private

  def submit_request(params)
    @response_http_code = @session.post("/api/v1/participant-declarations",
                                        params: params,
                                        headers: { "Authorization": "Bearer #{@token}" })

    @response = JSON.parse(@session.response.body)
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
end
