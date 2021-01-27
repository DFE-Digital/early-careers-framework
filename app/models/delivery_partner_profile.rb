# frozen_string_literal: true

class DeliveryPartnerProfile < ApplicationRecord
  belongs_to :user
  belongs_to :delivery_partner
end
