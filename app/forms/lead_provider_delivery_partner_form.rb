# frozen_string_literal: true

class LeadProviderDeliveryPartnerForm
  include ActiveModel::Model

  attr_accessor :delivery_partner_id

  validates :delivery_partner_id, presence: { message: "Choose a delivery partner" }
end
