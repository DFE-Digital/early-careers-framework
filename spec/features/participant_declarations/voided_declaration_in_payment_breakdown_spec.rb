# frozen_string_literal: true

require "rails_helper"
require_relative "./participant_declaration_steps"

RSpec.feature "Voided declaration in payment breakdown", type: :feature do
  include ParticipantDeclarationSteps

  before(:each) { setup }

  scenario "Payment breakdown does not include voided declarations" do
    given_an_early_career_teacher_has_been_entered_onto_the_dfe_service
    and_call_off_contract_was_created_for_lead_provider
    when_the_participant_details_are_passed_to_the_lead_provider
    and_the_lead_provider_submits_a_declaration_for_the_ect_using_their_id
    and_participant_declaration_made_eligible_for_payment
    and_the_lead_provider_voids_a_declaration
    and_breakdown_calculation_was_run
    then_the_payment_breakdown_does_not_include_voided_declaration
  end

private

  def and_call_off_contract_was_created_for_lead_provider
    create(:call_off_contract, lead_provider: @cpd_lead_provider.lead_provider, cohort: @statement.cohort)
  end

  def and_breakdown_calculation_was_run
    @breakdown = Finance::ECF::CalculationOrchestrator.new(
      statement: @statement,
      contract: @cpd_lead_provider.lead_provider.call_off_contract,
      aggregator: Finance::ECF::ParticipantAggregator.new(statement: @statement),
      calculator: PaymentCalculator::ECF::PaymentCalculation,
    ).call(event_type: :started)
  end

  def and_participant_declaration_made_eligible_for_payment
    travel_to @submission_date + 1.day do
      ParticipantDeclaration.find_by_id(@declaration_id).eligible!
    end
  end

  def then_the_payment_breakdown_does_not_include_voided_declaration
    expect(@breakdown.dig(:breakdown_summary, :participants)).to eq(0)
  end
end
