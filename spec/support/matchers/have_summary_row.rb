# frozen_string_literal: true

module Support
  module HaveSummaryRow
    extend RSpec::Matchers::DSL

    define :have_summary_row do |key, value|
      match do |actual|
        key_node = find_key_node(actual, key)
        value_node = find_value_node(key_node)
        if value_node.text != value
          @failure_message = "Expected summary row \"#{key}\" with value \"#{value}\" but value \"#{value_node.text}\" found instead"
          return false
        end
        true
      rescue Capybara::ElementNotFound
        false
      end

      failure_message do
        @failure_message || "Can't find a summary row where the key is \"#{key}\" and the value is \"#{value}\""
      end

      description do
        "have summary row where the key is \"#{key}\" and the value is \"#{value}\""
      end

      def find_key_node(actual, key)
        actual.find("dt.govuk-summary-list__key", text: key)
      rescue Capybara::ElementNotFound
        @failure_message = "Can't find a summary row where the key is \"#{key}\""
        raise
      end

      def find_value_node(key_node)
        key_node.sibling("dd.govuk-summary-list__value")
      end
    end

    define :have_summary_row_action do |key, action|
      match do |actual|
        key_node = find_key_node(actual, key)
        action_node = find_action_node(key_node)
        if action_node.text(:all) != action
          @failure_message = "Expected summary row \"#{key}\" with action \"#{action}\" but \"#{action_node.text}\" found instead"
          return false
        end
        true
      rescue Capybara::ElementNotFound
        false
      end

      failure_message do
        @failure_message || "Can't find a summary row where the key is \"#{key}\" and the action is \"#{action}\""
      end

      description do
        "have summary row where the key is \"#{key}\" and the action is \"#{action}\""
      end

      def find_key_node(actual, key)
        actual.find("dt.govuk-summary-list__key", text: key)
      rescue Capybara::ElementNotFound
        @failure_message = "Can't find a summary row where the key is \"#{key}\""
        raise
      end

      def find_action_node(key_node)
        key_node.sibling("dd.govuk-summary-list__actions")
      end
    end

    RSpec.configure do |rspec|
      rspec.include self, type: :feature
    end
  end
end
