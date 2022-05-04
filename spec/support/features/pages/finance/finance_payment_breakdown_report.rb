# frozen_string_literal: true

require_relative "../base"

module Sections
  class StatementSelector < SitePrism::Section
    set_default_search_arguments ".statement-selector"

    element :lead_provider, "select[name=\"lead_provider\"]"
    element :statement, "select[name=\"statement\"]"
    element :view_button, "button"

    def view_lead_provider(lead_provider_name)
      lead_provider.select lead_provider_name
      click_on "View"
    end

    def has_lead_provider_selected?(lead_provider_name)
      lead_provider.selected? lead_provider_name
    end

    def view_statement(statement_name)
      statement.select statement_name
      click_on "View"
    end

    def has_statement_selected?(statement_name)
      statement.selected? statement_name
    end
  end

  class SummaryFinancePanel < SitePrism::Section
    set_default_search_arguments ".finance-panel__summary"

    element :payment_total, ".finance-panel__summary__total-payment-breakdown > h4"
    element :payment_breakdown, ".finance-panel__summary__total-payment-breakdown > div"

    element :dates, ".finance-panel__summary__meta__dates"
    element :counts, ".finance-panel__summary__meta__counts"

    def has_payment_total?(total)
      payment_total.has_content? "Total £#{total}"
    end

    def has_output_payment?(output_payment)
      payment_breakdown.has_content? "Output payment £#{output_payment}"
    end

    def has_service_fee?(service_fee)
      payment_breakdown.has_content? "Service fee £#{service_fee}"
    end

    def has_adjustments?(adjustments)
      payment_breakdown.has_content? "Adjustments £#{adjustments}"
    end

    def has_vat?(vat_total)
      payment_breakdown.has_content? "VAT £#{vat_total}"
    end

    def has_milestone_cutoff_date?(cutoff_date)
      dates.has_content? "Milestone cut off date #{cutoff_date}"
    end

    def has_payment_date?(payment_date)
      dates.has_content? "Payment date #{payment_date}"
    end

    def has_total_starts?(total_starts)
      counts.has_content? "Total starts #{total_starts}"
    end

    def has_total_retained?(total_retained)
      counts.has_content? "Total retained #{total_retained}"
    end

    def has_total_completed?(total_completed)
      counts.has_content? "Total completed #{total_completed}"
    end

    def has_total_voided?(total_voided)
      counts.has_content? "Total voided #{total_voided}"
    end

    def view_voided_declarations
      counts.click_on "voided declarations"

      # Pages::FinanceVoidedDeclarationsReport.loaded
    end
  end

  class OutputPaymentsFinancePanel < SitePrism::Section
    set_default_search_arguments ".finance-panel__output-payments"

    elements :output_payments, ".output-payments tbody > tr"

    def has_output_payment?(output_payment)
      has_content? "Output payment total £#{output_payment}"
    end

    def has_started_declarations?(band_a_total = 0, band_b_total = 0, band_c_total = 0, band_d_total = 0, payment_total = "")
      output_payments[0].has_content? "Starts #{band_a_total} #{band_b_total} #{band_c_total} #{band_d_total} #{payment_total}"
    end

    def has_retained_1_declarations?(band_a_total = 0, band_b_total = 0, band_c_total = 0, band_d_total = 0, payment_total = "")
      output_payments[2].has_content? "Retained 1 #{band_a_total} #{band_b_total} #{band_c_total} #{band_d_total} #{payment_total}"
    end
  end

  class AdjustmentsFinancePanel < SitePrism::Section
    set_default_search_arguments ".finance-panel__adjustments"

    # cols: Adjustment type, Number of trainees, Fee per trainee, Payments
    elements :adjustments, "table tbody > tr"

    def has_uplift_payment?(num_participants = 0, total_uplift = "0.00")
      adjustments[0].has_content? "Uplift fee #{num_participants} £100.00 £#{total_uplift}"
    end

    def has_total?(total_adjustments = "0.00")
      has_content? "Adjustments total £#{total_adjustments}"
    end
  end

  class ContractInformationFinancePanel < SitePrism::Section
    set_default_search_arguments "details"
  end
end

module Pages
  class FinancePaymentBreakdownReport < ::Pages::Base
    set_url "/finance/ecf/payment_breakdowns/{lead_provider_id}/statements/{statement_name}"
    set_primary_heading "Early career framework (ECF)"

    section :statement_selector, Sections::StatementSelector
    section :summary_panel, Sections::SummaryFinancePanel
    section :output_payments_panel, Sections::OutputPaymentsFinancePanel
    section :adjustments_panel, Sections::AdjustmentsFinancePanel
    section :contract_information_panel, Sections::ContractInformationFinancePanel

    def can_see_payment_summary?(num_declarations)
      payment_total = num_declarations == 0 ? "0.00" : "100.00"

      summary_panel.has_output_payment? payment_total
    end

    def can_see_started_declaration_payment_table?(num_ects, num_mentors, num_declarations)
      total_in_band = (num_ects + num_mentors) * num_declarations
      total_payment = total_in_band == 0 ? "0.00" : "119.40"

      output_payments_panel.has_started_declarations? total_in_band, 0, 0, 0, total_payment
    end

    def can_see_retained_1_declaration_payment_table?(num_ects, num_mentors, num_declarations)
      total_in_band = (num_ects + num_mentors) * num_declarations
      total_payment = total_in_band == 0 ? "0.00" : "119.40"

      output_payments_panel.has_retained_1_declarations? total_in_band, 0, 0, 0, total_payment
    end

    def can_see_other_fees_table?(num_ects, num_mentors)
      num_participants = num_ects + num_mentors
      total_payment = num_participants == 0 ? "0.00" : "100.00"
      total_uplift = "100.00"

      output_payments_panel.has_output_payment? total_payment
      adjustments_panel.has_uplift_payment? num_participants, total_uplift
    end
  end
end
