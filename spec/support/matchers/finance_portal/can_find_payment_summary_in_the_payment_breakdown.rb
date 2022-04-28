# frozen_string_literal: true

module Support
  module FindingPaymentSummaryInPaymentBreakdown
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :be_able_to_see_payment_summary_for_lead_provider_in_payment_breakdown do |lead_provider_name, num_declarations, scenario|
      match do |finance_user|
        sign_in_as finance_user

        report = Pages.finance_portal
                  .view_payment_breakdown
                  .complete(lead_provider_name)

        result = if num_declarations.zero?
                   report.total_declarations.zero?
                 else
                   report.declaration_in_band?(scenario.new_declarations, "Band A")
                 end

        sign_out
        result
      end
    end
  end
end
