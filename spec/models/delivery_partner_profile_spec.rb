# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeliveryPartnerProfile, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:delivery_partner) }
  end
end
