# frozen_string_literal: true

RSpec.describe DeliveryPartners::UpdateUserForm, type: :model do
  let(:user) { create(:user, full_name: "Example Name", email: "madeup@example.com") }
  let(:delivery_partner_1) { create(:delivery_partner) }
  let(:delivery_partner_2) { create(:delivery_partner) }

  let(:delivery_partner_profile) { create(:delivery_partner_profile, user:, delivery_partner: delivery_partner_1) }

  let(:params) { { full_name: "Test 1", email: "test@example.com", delivery_partner_id: delivery_partner_2.id } }

  subject(:form) { described_class.new(delivery_partner_profile:) }

  it { is_expected.to validate_presence_of(:full_name).on(:name).with_message("Enter a full name") }
  it { is_expected.to validate_presence_of(:email).on(:email).with_message("Enter an email address") }
  it { is_expected.to validate_presence_of(:delivery_partner_id).on(:delivery_partner_id).with_message("Choose a delivery partner") }

  describe ".update" do
    context "valid params" do
      it "should change delivery partner user details" do
        delivery_partner_profile.reload
        expect(delivery_partner_profile.user.full_name).to eql("Example Name")
        expect(delivery_partner_profile.user.email).to eql("madeup@example.com")
        expect(delivery_partner_profile.delivery_partner).to eql(delivery_partner_1)

        expect(form.update(params)).to be true

        delivery_partner_profile.reload
        expect(delivery_partner_profile.user.full_name).to eql("Test 1")
        expect(delivery_partner_profile.user.email).to eql("test@example.com")
        expect(delivery_partner_profile.delivery_partner).to eql(delivery_partner_2)
      end
    end

    context "invalid params" do
      let(:params) { { full_name: nil, email: nil, delivery_partner_id: nil } }

      it "should not create delivery partner user" do
        expect(form.update(params)).to be false
      end
    end
  end
end
