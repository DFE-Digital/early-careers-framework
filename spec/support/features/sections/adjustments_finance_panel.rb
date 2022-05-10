# frozen_string_literal: true

require_relative "../sections/base_section"

module Sections
  class AdjustmentsFinancePanel < Sections::BaseSection
    set_default_search_arguments ".finance-panel__adjustments"

    # cols: Adjustment type, Number of trainees, Fee per trainee, Payments
    elements :adjustments, "table tbody > tr"

    def has_uplift_payments?(num_participants = 0)
      element_has_content? adjustments[0], "Uplift fee #{num_participants}".strip
    end

    def has_total?(total_adjustments = "0.00")
      element_has_content? self, "Adjustments total £#{total_adjustments}"
    end
  end
end
