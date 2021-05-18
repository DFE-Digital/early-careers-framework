# frozen_string_literal: true

module CurrencyParser
  def currency_to_big_decimal(value)
    # This isn't elegant or production code, but it's just to parse the Gherkin feature files.
    value.gsub(",", "").gsub("£", "").to_d # strip thousand separators and leading currency symbol
  end
end
