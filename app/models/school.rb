# frozen_string_literal: true

class School < ApplicationRecord
  paginates_per 3
  belongs_to :network, optional: true
  has_one :partnership
  has_one :lead_provider, through: :partnership
  has_and_belongs_to_many :induction_coordinator_profiles

  def full_address
    address = <<~ADDRESS
      #{address_line1}
      #{address_line2}
      #{address_line3}
      #{address_line4}
      #{postcode}
    ADDRESS
    address.squeeze("\n")
  end

  def fully_registered?
    induction_coordinator_profiles
      .joins(:user)
      .where.not(users: { confirmed_at: nil })
      .any?
  end

  def not_registered?
    induction_coordinator_profiles.none?
  end

  def partially_registered?
    return false if not_registered?

    induction_coordinator_profiles
      .joins(:user)
      .where.not(users: { confirmed_at: nil })
      .none?
  end
end
