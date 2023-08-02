# frozen_string_literal: true

require "rails_helper"

describe Admin::DeliveryPartners::Exporter do
  let(:instance) { described_class.new }

  describe "#csv" do
    subject { instance.csv }

    it "returns a CSV of all delivery partners ordered by user full_name" do
      user1 = create(:user, full_name: "Ben Smith")
      user2 = create(:user, full_name: "Andrew Jones")

      delivery_partner_profile1 = create(:delivery_partner_profile, user: user1)
      delivery_partner_profile2 = create(:delivery_partner_profile, user: user1)
      delivery_partner_profile3 = create(:delivery_partner_profile, user: user2)

      delivery_partner1 = delivery_partner_profile1.delivery_partner
      delivery_partner2 = delivery_partner_profile2.delivery_partner
      delivery_partner3 = delivery_partner_profile3.delivery_partner

      is_expected.to eq(
        <<~CSV,
          Full name,Email,Delivery Partner ID,Delivery Partner Name
          #{user2.full_name},#{user2.email},#{delivery_partner3.id},#{delivery_partner3.name}
          #{user1.full_name},#{user1.email},#{delivery_partner1.id},#{delivery_partner1.name}
          #{user1.full_name},#{user1.email},#{delivery_partner2.id},#{delivery_partner2.name}
        CSV
      )
    end
  end
end
