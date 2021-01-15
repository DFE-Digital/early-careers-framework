# frozen_string_literal: true

class Cohort < ApplicationRecord
  def display_name
    "#{start_year} to #{start_year + 2}"
  end
end
