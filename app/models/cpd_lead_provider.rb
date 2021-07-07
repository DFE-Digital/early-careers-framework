# frozen_string_literal: true

class CpdLeadProvider < ApplicationRecord
  validates :name, presence: { message: "Enter a name" }
end
