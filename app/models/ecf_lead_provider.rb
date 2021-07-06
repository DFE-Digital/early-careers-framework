# frozen_string_literal: true

class EcfLeadProvider < ApplicationRecord
  validates :name, presence: { message: "Enter a name" }
end
