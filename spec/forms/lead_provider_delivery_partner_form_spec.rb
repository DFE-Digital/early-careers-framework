# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadProviderDeliveryPartnerForm, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:delivery_partner_id).with_message("Choose a delivery partner") }
  end
end
