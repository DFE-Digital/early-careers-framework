# frozen_string_literal: true

require_relative "../sections/base_section"

module Sections
  class SummaryFinancePanel < Sections::BaseSection
    set_default_search_arguments ".finance-panel__summary"

    element :payment_total, ".finance-panel__summary__total-payment-breakdown > h4"
    element :payment_breakdown, ".finance-panel__summary__total-payment-breakdown > div"

    element :dates, ".finance-panel__summary__meta__dates"
    element :counts, ".finance-panel__summary__meta__counts"

    def has_payment_total?(total)
      element_has_content? payment_total, "Total £#{total}"
    end

    def has_output_payment?(output_payment)
      element_has_content? payment_breakdown, "Output payment\n£#{output_payment}".strip
    end

    def has_service_fee?(service_fee)
      element_has_content? payment_breakdown, "Service fee\n£#{service_fee}".strip
    end

    def has_adjustments?(adjustments)
      element_has_content? payment_breakdown, "Adjustments\n£#{adjustments}".strip
    end

    def has_vat?(vat_total)
      element_has_content? payment_breakdown, "VAT\n£#{vat_total}".strip
    end

    def has_milestone_cutoff_date?(cutoff_date)
      element_has_content? dates, "Milestone cut off date #{cutoff_date}"
    end

    def has_payment_date?(payment_date)
      element_has_content? dates, "Payment date #{payment_date}"
    end

    def has_total_starts?(total_starts)
      element_has_content? counts, "Total starts\n#{total_starts}"
    end

    def has_total_retained?(total_retained)
      element_has_content? counts, "Total retained\n#{total_retained}"
    end

    def has_total_completed?(total_completed)
      element_has_content? counts, "Total completed\n#{total_completed}"
    end

    def has_total_voided?(total_voided)
      element_has_content? counts, "Total voided\n#{total_voided}"
    end

    def view_voided_declarations
      counts.click_on "voided declarations"

      # Pages::FinanceVoidedDeclarationsReport.loaded
    end
  end
end
