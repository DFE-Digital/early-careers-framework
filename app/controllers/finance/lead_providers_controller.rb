# frozen_string_literal: true

class Finance::LeadProvidersController < Finance::BaseController
  skip_after_action :verify_policy_scoped

  def index
    @ecf_lead_providers = LeadProvider.all
  end

  def show
    ecf_lead_provider = lead_provider_scope.find(params[:id])

    calculations = CalculationOrchestrator.call(
      cpd_lead_provider: ecf_lead_provider.cpd_lead_provider,
      contract: ecf_lead_provider.call_off_contract,
      event_type: :started,
    )

    @heading = Heading.new(calculations[:headings])
    @service_fees = ServiceFeeCollection.new(calculations[:service_fees])
    @output_payments = OutputPaymentCollection.new(calculations[:output_payments])
    @other_fees = OtherFeeCollection.new(calculations[:other_fees])
  end

private

  def lead_provider_scope
    policy_scope(LeadProvider, policy_scope_class: FinanceProfilePolicy::Scope)
  end
end
