# frozen_string_literal: true

class DiscardableRecord < ApplicationRecord
  self.abstract_class = true
  include Discard::Model
  default_scope -> { kept }
end
