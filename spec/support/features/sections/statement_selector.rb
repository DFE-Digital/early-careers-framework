# frozen_string_literal: true

require_relative "../sections/base_section"

module Sections
  class StatementSelector < Sections::BaseSection
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
      puts("END_TO_END_SCENARIO: #{statement_name}")
      statement.select statement_name
      click_on "View"
    end

    def has_statement_selected?(statement_name)
      statement.selected? statement_name
    end
  end
end
