# frozen_string_literal: true

class School < ApplicationRecord
  CONFIRMATION_WINDOW = 24

  belongs_to :network, optional: true

  # TODO: Register and Partner 150: Handle schools changing LAs and LADs
  belongs_to :local_authority_district, optional: true
  belongs_to :local_authority, optional: true
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
    confirmed_induction_coordinators.any?
  end

  def not_registered?
    induction_coordinator_profiles.none?
  end

  def partially_registered?
    return false if fully_registered?

    unconfirmed_induction_coordinators
      &.where("users.confirmation_sent_at > ?", CONFIRMATION_WINDOW.hours.ago)
      &.any?
  end

private

  def unconfirmed_induction_coordinators
    induction_coordinator_profiles
      &.joins(:user)
      &.where(users: { confirmed_at: nil })
  end

  def confirmed_induction_coordinators
    induction_coordinator_profiles
      &.joins(:user)
      &.where&.not(users: { confirmed_at: nil })
  end
end
