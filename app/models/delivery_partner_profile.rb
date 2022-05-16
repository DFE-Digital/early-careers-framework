# frozen_string_literal: true

class DeliveryPartnerProfile < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :delivery_partner

  def self.create_delivery_partner_user(full_name, email, delivery_partner)
    ActiveRecord::Base.transaction do
      user = User.create!(full_name: full_name, email: email)
      dpp = DeliveryPartnerProfile.create!(user: user, delivery_partner: delivery_partner)
      DeliveryPartnerProfileMailer.welcome(delivery_partner_profile: dpp).deliver_now
    end
  end
end
