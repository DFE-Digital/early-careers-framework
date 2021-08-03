# frozen_string_literal: true

module FinanceHelper
  def number_to_pounds(number)
    number_to_currency number, precision: 2, unit: "£"
  end
end
