# frozen_string_literal: true

require_relative "../base_page"

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

    def payment_total
      payment_total.text
    end

    def has_payment_total?(total)
      expected = "Total £#{total}"
      payment_total.has_content? expected
    end

    def output_payment
      payment_breakdown.text
    end

    def has_output_payment?(output_payment)
      expected = "Output payment £#{output_payment}".strip
      payment_breakdown.has_content? expected
    end

    def has_service_fee?(service_fee)
      expected = "Output payment £#{service_fee}".strip
      payment_breakdown.has_content? expected
    end

    def has_adjustments?(adjustments)
      expected = "Output payment £#{adjustments}".strip
      payment_breakdown.has_content? expected
    end

    def has_vat?(vat_total)
      expected = "Output payment £#{vat_total}".strip
      payment_breakdown.has_content? expected
    end

    def has_milestone_cutoff_date?(cutoff_date)
      dates.has_content? "Milestone cut off date #{cutoff_date}"
    end

    def has_payment_date?(payment_date)
      dates.has_content? "Payment date #{payment_date}"
    end

    def has_total_starts?(total_starts)
      counts.has_content? "Total starts\n#{total_starts}"
    end

    def has_total_retained?(total_retained)
      counts.has_content? "Total retained\n#{total_retained}"
    end

    def has_total_completed?(total_completed)
      counts.has_content? "Total completed\n#{total_completed}"
    end

    def has_total_voided?(total_voided)
      counts.has_content? "Total voided\n#{total_voided}"
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
      expected = "Output payment total\n£#{output_payment}".strip
      has_content? expected
    end

    def has_started_declarations?(band_a_total = 0, band_b_total = 0, band_c_total = 0, band_d_total = 0)
      expected = "Starts #{band_a_total} #{band_b_total} #{band_c_total} #{band_d_total}".strip
      output_payments[0].has_content? expected
    end

    def has_retained_1_declarations?(band_a_total = 0, band_b_total = 0, band_c_total = 0, band_d_total = 0)
      expected = "Retained 1 #{band_a_total} #{band_b_total} #{band_c_total} #{band_d_total}".strip
      output_payments[2].has_content? expected
    end
  end

  class AdjustmentsFinancePanel < SitePrism::Section
    set_default_search_arguments ".finance-panel__adjustments"

    # cols: Adjustment type, Number of trainees, Fee per trainee, Payments
    elements :adjustments, "table tbody > tr"

    def has_uplift_payments?(num_participants = 0)
      expected = "Uplift fee #{num_participants}".strip
      adjustments[0].has_content? expected
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
  class FinancePaymentBreakdownReport < ::Pages::BasePage
    set_url "/finance/ecf/payment_breakdowns/{lead_provider_id}/statements/{statement_name}"
    set_primary_heading "Early career framework (ECF)"

    section :statement_selector, Sections::StatementSelector
    section :summary_panel, Sections::SummaryFinancePanel
    section :output_payments_panel, Sections::OutputPaymentsFinancePanel
    section :adjustments_panel, Sections::AdjustmentsFinancePanel
    section :contract_information_panel, Sections::ContractInformationFinancePanel

    def has_payment_summary?(num_declarations)
      payment_total = num_declarations == 0 ? "0.00" : "119.40"

      summary_panel.has_output_payment? payment_total
    end

    def has_declaration_counts?(starts_count, retained_count, completed_count, voided_count)
      summary_panel.has_total_starts? starts_count
      summary_panel.has_total_retained? retained_count
      summary_panel.has_total_completed? completed_count
      summary_panel.has_total_voided? voided_count
    end

    def has_started_declaration_payment_table?(num_ects, num_mentors, num_declarations)
      total_in_band = (num_ects + num_mentors) * num_declarations

      output_payments_panel.has_started_declarations? total_in_band, 0, 0, 0
    end

    def has_retained_1_declaration_payment_table?(num_ects, num_mentors, num_declarations)
      total_in_band = (num_ects + num_mentors) * num_declarations

      output_payments_panel.has_retained_1_declarations? total_in_band, 0, 0, 0
    end

    def has_other_fees_table?(num_ects, num_mentors)
      num_participants = num_ects + num_mentors

      adjustments_panel.has_uplift_payments?(num_participants)
    end
  end
end
