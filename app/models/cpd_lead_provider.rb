# frozen_string_literal: true

class CpdLeadProvider < ApplicationRecord
  has_one :lead_provider
  has_one :npq_lead_provider

  validates :name, presence: { message: "Enter a name" }
end
