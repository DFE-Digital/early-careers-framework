# frozen_string_literal: true

module FinanceHelper
  def number_to_pounds(number)
    number_to_currency number, precision: 2, unit: "£"
  end

  def float_to_percentage(number)
    number_to_percentage(number * 100, precision: 0)
  end

  def band_to_identifier(index)
    ("A".ord + index).chr
  end
end
