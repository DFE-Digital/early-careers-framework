# frozen_string_literal: true

module Analytics
  class BaseRecord < ApplicationRecord
    self.abstract_class = true

    connects_to database: { writing: :analytics } if %w[test development production].include? Rails.env
  end
end
