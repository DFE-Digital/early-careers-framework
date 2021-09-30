# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_declaration_steps"

RSpec.feature "Voided declaration in payment breakdown", type: :feature do
  include ParticipantDeclarationSteps

  before(:each) do
    setup
  end

  scenario "Payment breakdown does not include voided declarations" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    and_call_off_contract_was_created_for_lead_provider
    when_the_participant_details_are_passed_to_the_lead_provider
    @declaration_id = and_the_lead_provider_submits_a_declaration_for_the_ect_using_their_id.dig("data", "id")
    and_the_lead_provider_voids_a_declaration
    and_profile_declaration_made_payable
    and_breakdown_calculation_was_run
    then_the_payment_breakdown_does_not_include_voided_declaration
  end

private

  def and_call_off_contract_was_created_for_lead_provider
    create(:call_off_contract, lead_provider: @cpd_lead_provider.lead_provider)
  end

  def and_breakdown_calculation_was_run
    @breakdown = CalculationOrchestrator.call(
      cpd_lead_provider: @cpd_lead_provider,
      contract: @cpd_lead_provider.lead_provider.call_off_contract,
      event_type: :started,
    )
  end

  def and_profile_declaration_made_payable
    profile_declaration = ProfileDeclaration.find_by(participant_declaration_id: @declaration_id)
    profile_declaration.update!({ payable: true })
  end

  def then_the_payment_breakdown_does_not_include_voided_declaration
    expect(@breakdown.dig(:breakdown_summary, :ects)).to eq(0)
  end
end
