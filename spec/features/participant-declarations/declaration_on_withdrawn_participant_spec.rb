# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_declaration_steps"

RSpec.feature "Declaration on withdrawn participant", type: :feature do
  include ParticipantDeclarationSteps

  before(:each) do
    setup
  end

  scenario "Declaration submitted for a withdrawn participant" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_provider_withdraws_a_participant
    then_the_declaration_made_against_the_withdrawn_participant_is_rejected
  end
end
