# frozen_string_literal: true

# Convert decimal strings to decimal values. Ref: https://github.com/jnicklas/turnip#custom-step-placeholders
placeholder :decimal_placeholder do
  match(/[,.\d]+/) do |matched_decimal|
    CurrencyParser.currency_to_big_decimal(matched_decimal)
  end
end
