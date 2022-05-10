# frozen_string_literal: true

require_relative "../../sections/statement_selector"
require_relative "../../sections/summary_finance_panel"
require_relative "../../sections/output_payments_finance_panel"
require_relative "../../sections/adjustments_finance_panel"
require_relative "../../sections/contract_information_finance_panel"

module Pages
  class FinancePaymentBreakdownReport < Pages::BasePage
    set_url "/finance/ecf/payment_breakdowns/{lead_provider_id}/statements/{statement_name}"
    set_primary_heading "Early career framework (ECF)"

    section :statement_selector, Sections::StatementSelector
    section :summary_panel, Sections::SummaryFinancePanel
    section :output_payments_panel, Sections::OutputPaymentsFinancePanel
    section :adjustments_panel, Sections::AdjustmentsFinancePanel
    section :contract_information_panel, Sections::ContractInformationFinancePanel

    def has_payment_summary?(total)
      summary_panel.has_output_payment? total
    end

    def has_started_declarations_total?(total)
      summary_panel.has_total_starts? total
    end

    def has_retained_declarations_total?(total)
      summary_panel.has_total_retained? total
    end

    def has_completed_declarations_total?(total)
      summary_panel.has_total_completed? total
    end

    def has_voided_declarations_total?(total)
      summary_panel.has_total_voided? total
    end

    def has_started_declaration_payment_table?(num_ects: 0, num_mentors: 0, num_declarations: 0)
      output_payments_panel.has_started_declarations? (num_ects + num_mentors) * num_declarations, 0, 0, 0
    end

    def has_retained_1_declaration_payment_table?(num_ects: 0, num_mentors: 0, num_declarations: 0)
      output_payments_panel.has_retained_1_declarations? (num_ects + num_mentors) * num_declarations, 0, 0, 0
    end

    def has_other_fees_table?(num_ects: 0, num_mentors: 0)
      adjustments_panel.has_uplift_payments? num_ects + num_mentors
    end
  end
end
