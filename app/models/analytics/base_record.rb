# frozen_string_literal: true

module Analytics
  class BaseRecord < ApplicationRecord
    self.abstract_class = true
  end
end
