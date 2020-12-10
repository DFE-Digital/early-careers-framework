# frozen_string_literal: true

class School < ApplicationRecord
  belongs_to :network, optional: true
  has_one :partnership
  has_one :lead_provider, through: :partnership
end
