# frozen_string_literal: true

class LeadProvider < ApplicationRecord
  has_many :partnerships
  has_many :schools, through: :partnerships
  has_many :lead_provider_profiles
  has_many :users, through: :lead_provider_profiles
  has_many :provider_relationships
  has_many :delivery_partners, through: :provider_relationships

  validates :name, presence: { message: "Enter a name" }
end
