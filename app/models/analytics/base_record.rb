# frozen_string_literal: true

module Analytics
  class BaseRecord < ApplicationRecord
    self.abstract_class = true

    connects_to database: { writing: :analytics } unless Rails.env.review?
  end
end
