# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Submit participant declarations", type: :feature do
  before(:each) do
    setup
  end

  scenario "ECT details sent to provider, declaration sent using same unique ID, no errors in declaration" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_ect_using_their_id
    then_the_declaration_made_is_valid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_was_successful
  end

  scenario "ECT details sent to provider, declaration sent using same unique ID, errors exist in declaration" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_and_invalid_participant_id
    then_the_declaration_made_is_invalid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
  end

  scenario "ECT details sent to provider, declaration sent using different unique ID, errors exist in declaration" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_without_participant_id
    then_the_declaration_made_is_invalid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
  end

  scenario "Mentor details sent to provider, declaration sent using same unique ID, no errors in declaration" do
    given_an_ecf_mentor_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_mentor_using_their_id
    then_the_declaration_made_is_valid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_was_successful
  end

  scenario "Mentor details sent to provider, declaration sent using same unique ID, errors exist in declaration" do
    given_an_ecf_mentor_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_and_invalid_participant_id
    then_the_declaration_made_is_invalid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
  end

  scenario "Mentor details sent to provider, declaration sent using different unique ID, errors exist in declaration" do
    given_an_ecf_mentor_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_without_participant_id
    then_the_declaration_made_is_invalid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
  end

  scenario "NPQ participant details sent to provider, declaration sent using same unique ID, no errors in declaration" do
    given_an_npq_participant_has_been_entered_onto_the_dfe_service
    when_the_npq_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_npq_using_their_id
    then_the_declaration_made_is_valid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_was_successful
  end

  scenario "NPQ participant details sent to provider, declaration sent using same unique ID, errors exist in declaration" do
    given_an_npq_participant_has_been_entered_onto_the_dfe_service
    when_the_npq_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_participant_using_and_invalid_participant_id
    then_the_declaration_made_is_invalid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
  end

  scenario "NPQ participant details sent to provider, declaration sent using different unique ID, errors exist in declaration" do
    given_an_npq_participant_has_been_entered_onto_the_dfe_service
    when_the_npq_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_without_participant_id
    then_the_declaration_made_is_invalid
    and_the_lead_provider_receives_a_response_to_confirm_that_the_declaration_has_a_validation_error
  end

private

  def given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    ect_profile = create(:participant_profile, :ect)
    delivery_partner = create(:delivery_partner)
    create(:partnership,
           school: ect_profile.school,
           lead_provider: @cpd_lead_provider.lead_provider,
           cohort: ect_profile.cohort,
           delivery_partner: delivery_partner)

    @ect_id = ect_profile.user.id
    travel_to ect_profile.schedule.milestones.first.start_date + 1.day
  end

  def given_an_ecf_mentor_has_been_entered_onto_the_dfe_service
    partnership = create(:partnership, lead_provider: @lead_provider)
    mentor_profile = create(:participant_profile, :mentor, school: partnership.school, cohort: partnership.cohort)
    @mentor_id = mentor_profile.user.id
    travel_to mentor_profile.schedule.milestones.first.start_date + 1.day
  end

  def given_an_npq_participant_has_been_entered_onto_the_dfe_service
    create(:schedule, name: "ECF September standard 2021")
    npq_lead_provider = create(:npq_lead_provider, cpd_lead_provider: @cpd_lead_provider)
    npq_course = create(:npq_course, identifier: "npq-leading-teaching")
    npq_validation_data = create(:npq_validation_data, npq_lead_provider: npq_lead_provider, npq_course: npq_course)
    @npq_id = npq_validation_data.user.id

    NPQ::CreateOrUpdateProfile.new(npq_validation_data: npq_validation_data).call

    travel_to npq_validation_data.profile.schedule.milestones.first.start_date + 1.day
  end

  def when_the_participant_details_are_passed_to_the_lead_provider
    @session.get("/api/v1/participants",
                 headers: { "Authorization": "Bearer #{@token}" })

    participants = JSON.parse(@session.response.body).dig("data").map { |participant| participant["id"] }
    expect(participants.first).to eq([@ect_id, @mentor_id, @npq_id].compact.first)
  end

  def when_the_npq_participant_details_are_passed_to_the_lead_provider
    @session.get("/api/v1/npq-applications",
                 headers: { "Authorization": "Bearer #{@token}" })

    participant = JSON.parse(@session.response.body).dig("data", 0, "attributes", "participant_id")
    expect(participant).to eq([@ect_id, @mentor_id, @npq_id].compact.first)
  end

  def and_the_lead_provider_submits_a_declaration_for_the_ect_using_their_id
    params = common_params(@ect_id, "ecf-induction")
    submit_request(params)
  end

  def and_the_lead_provider_submits_a_declaration_for_the_mentor_using_their_id
    params = common_params(@mentor_id, "ecf-mentor")
    submit_request(params)
  end

  def and_the_lead_provider_submits_a_declaration_for_the_npq_using_their_id
    params = common_params(@npq_id, "npq-leading-teaching")
    submit_request(params)
  end

  def and_the_lead_provider_submits_a_declaration_for_the_participant_using_and_invalid_participant_id
    params = common_params("111-222-333-444-555")
    submit_request(params)
  end

  def and_the_lead_provider_submits_a_declaration_without_participant_id
    params = common_params("", "ecf-induction")
    params["data"]["attributes"].reject! { |a| a["participant_id"] }
    submit_request(params)
  end

  def then_the_declaration_made_is_valid
    expect(ParticipantDeclaration.find(@response["data"]["id"])).to be_present
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
    @lead_provider = create(:lead_provider)
    @cpd_lead_provider = create(:cpd_lead_provider, lead_provider: @lead_provider)
    @token = LeadProviderApiToken.create_with_random_token!(cpd_lead_provider: @cpd_lead_provider)
    @session = ActionDispatch::Integration::Session.new(Rails.application)

    @params = common_params(@participant_id, "ecf-induction")
  end

  def submit_request(params)
    @response_http_code = @session.post("/api/v1/participant-declarations",
                                        params: params,
                                        headers: { "Authorization": "Bearer #{@token}" })
    @response = JSON.parse(@session.response.body)
  end

  def common_params(participant_id, course_identifier = "ecf-induction", declaration_date = Time.zone.now)
    JSON.parse(<<~DATA)
      {
      "data":{
        "type":"participant-declaration",
        "attributes": {
           "participant_id": "#{participant_id}",
           "declaration_type": "started",
           "declaration_date": "#{declaration_date.rfc3339}",
      		 "course_identifier": "#{course_identifier}"
         }
       }
      }
    DATA
  end
end
