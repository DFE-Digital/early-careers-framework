# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_declaration_steps"

RSpec.feature "Block participant declaration paid twice", type: :feature do
  include ParticipantDeclarationSteps

  before(:each) do
    setup
  end

  scenario "Declaration submitted for a changed schedule" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_ect_using_their_id
    then_the_declaration_made_is_valid
    and_schedule_change_is_submitted_for_this_participant
    and_the_lead_provider_submits_a_declaration_for_the_ect_using_their_id
    then_second_declaration_is_not_created
  end

  scenario "Declaration submitted for a changed lead provider" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_ect_using_their_id
    then_the_declaration_made_is_valid
    and_lead_provider_changed_for_the_participant
    and_the_lead_provider_submits_a_declaration_for_the_ect_using_their_id
    then_second_declaration_is_not_created
  end
end
