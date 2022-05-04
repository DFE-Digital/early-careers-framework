# frozen_string_literal: true

module Support
  module HaveSummaryRow
    extend RSpec::Matchers::DSL

    define :have_summary_row do |key, value|
      match do |actual|
        begin
          key_node = find_key_node(actual, key)
          value_node = find_value_node(key_node)
          expect(value_node).to have_content(value)
        rescue Capybara::ElementNotFound
          false
        end
      end

      failure_message do |actual|
        @failure_message || "Can't find a summary row where the key is \"#{key}\" and the value is \"#{value}\""
      end

      description do
        "have summary row where the key is \"#{key}\" and the value is \"#{value}\""
      end

      def find_key_node(actual, key)
        begin
          actual.find("dt.govuk-summary-list__key", text: key)
        rescue Capybara::ElementNotFound
          @failure_message = "Can't find a summary row where the key is \"#{key}\""
          raise
        end
      end

      def find_value_node(key_node)
        key_node.sibling("dd.govuk-summary-list__value")
      end
    end

    RSpec.configure do |rspec|
      rspec.include self, type: :feature
    end
  end
end
