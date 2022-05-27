# frozen_string_literal: true

require_relative "../sections/base_section"

module Sections
  class OutputPaymentsFinancePanel < Sections::BaseSection
    set_default_search_arguments ".finance-panel__output-payments"

    elements :output_payments, ".output-payments tbody > tr"

    def has_output_payment?(output_payment)
      element_has_content? self, "Output payment total\n£#{output_payment}".strip
    end

    def has_started_declarations?(band_a_total = 0, band_b_total = 0, band_c_total = 0, band_d_total = 0)
      element_has_content? output_payments[0], "Starts #{band_a_total} #{band_b_total} #{band_c_total} #{band_d_total}".strip
    end

    def has_retained_1_declarations?(band_a_total = 0, band_b_total = 0, band_c_total = 0, band_d_total = 0)
      element_has_content? output_payments[2], "Retained 1 #{band_a_total} #{band_b_total} #{band_c_total} #{band_d_total}".strip
    end
  end
end
