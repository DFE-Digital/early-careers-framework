# frozen_string_literal: true

class DeliveryPartnerProfile < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :delivery_partner

  accepts_nested_attributes_for :user, :delivery_partner, update_only: true
  validates :delivery_partner_id, presence: true
  def self.create_delivery_partner_user(full_name, email, delivery_partner)
    ActiveRecord::Base.transaction do
      user = User.where(email:).first
      user ||= User.create!(full_name:, email:)
      dpp = DeliveryPartnerProfile.create!(user:, delivery_partner:)
      DeliveryPartnerProfileMailer.welcome(delivery_partner_profile: dpp).deliver_now
    end
  end
end
