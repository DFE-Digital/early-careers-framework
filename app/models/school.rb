# frozen_string_literal: true

class School < ApplicationRecord
  belongs_to :network, optional: true
  has_one :partnership
  has_one :lead_provider, through: :partnership
  has_and_belongs_to_many :induction_coordinator_profiles
  has_and_belongs_to_many :school_domains
end
