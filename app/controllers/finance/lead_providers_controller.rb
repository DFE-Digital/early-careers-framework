# frozen_string_literal: true

class Finance::LeadProvidersController < Finance::BaseController
  skip_after_action :verify_policy_scoped

  def index
    @ecf_lead_providers = LeadProvider.all
  end

  def show
    @ecf_lead_provider = lead_provider_scope.find(params[:id])
    cpd_lead_provider = @ecf_lead_provider.cpd_lead_provider

    @breakdown = CalculationOrchestrator.call(
      cpd_lead_provider: cpd_lead_provider,
      contract: @ecf_lead_provider.call_off_contract,
    )

    @total_ect = ParticipantEventAggregator.call({ cpd_lead_provider: cpd_lead_provider, started: :count_active_ects_for_lead_provider })
    @total_mentors = ParticipantEventAggregator.call({ cpd_lead_provider: cpd_lead_provider, started: :count_active_mentors_for_lead_provider })
    @total_participants = ParticipantEventAggregator.call({ cpd_lead_provider: cpd_lead_provider })
    @uplift_participants = ParticipantUpliftAggregator.call({ cpd_lead_provider: cpd_lead_provider })
  end

private

  def lead_provider_scope
    policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
  end
end
