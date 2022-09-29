# frozen_string_literal: true

module FinanceHelper
  include ActionView::Helpers::NumberHelper

  def number_to_pounds(number)
    number = 0 if number.zero?

    number_to_currency number, precision: 2, unit: "£"
  end

  def float_to_percentage(number)
    number_to_percentage(number * 100, precision: 0)
  end
end
