# frozen_string_literal: true

require_relative "../sections/base_section"

module Sections
  class SummaryRowSection < Sections::BaseSection
    element :key, 'dt.govuk-summary-list__key'
    element :value, 'dd.govuk-summary-list__value'
    element :actions, 'dd.govuk-summary-list__actions'
    elements :action_links, 'dd.govuk-summary-list__actions a'

    def find_action_link_by_text(text)
      action_links.find { |action_link| action_link.text == text }
    end

    def click_action(selector)
      link = find_action_link_by_text(selector)
      link.click
    end

    def have_key_value(key_text, value_text)
      key.text == key_text && value.text == value_text
    end
  end

  class SummaryListSection < Sections::BaseSection
    sections :rows, Sections::SummaryRowSection, '.govuk-summary-list__row'

    def find_row_by_key(text)
      rows.find { |row| row.key.text == text }
    end

    def click_action(key, selector)
      row = find_row_by_key(key)
      row.click_action(selector)
    end

    def have_key_value(key_text, value_text)
      rows.any? { |row| row.have_key_value(key_text, value_text) }
    end
  end

end
