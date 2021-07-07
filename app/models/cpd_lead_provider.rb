# frozen_string_literal: true

class CpdLeadProvider < ApplicationRecord
  has_many :lead_providers
  has_many :npq_lead_providers

  validates :name, presence: { message: "Enter a name" }
end
