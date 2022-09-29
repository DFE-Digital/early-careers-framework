# frozen_string_literal: true

require_relative "../sections/base_section"

module Sections
  class UpliftsFinancePanel < Sections::BaseSection
    set_default_search_arguments ".finance-panel__uplifts"

    # cols: Number of trainees, Fee per trainee, Payments
    elements :adjustments, "table tbody > tr"

    def has_uplift_payments?(num_participants = 0)
      element_has_content? adjustments[0], num_participants
    end
  end
end
