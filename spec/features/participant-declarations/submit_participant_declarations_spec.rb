# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_declaration_steps"

RSpec.feature "Submit participant declarations", type: :feature do
  include ParticipantDeclarationSteps

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
end
