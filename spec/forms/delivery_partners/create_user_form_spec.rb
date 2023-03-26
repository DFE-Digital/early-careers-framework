# frozen_string_literal: true

RSpec.describe DeliveryPartners::CreateUserForm, type: :model do
  let(:delivery_partner) { create(:delivery_partner) }
  let(:params) { { full_name: "Test 1", email: "test@example.com", delivery_partner_id: delivery_partner.id } }

  subject(:form) { described_class.new(params) }

  it { is_expected.to validate_presence_of(:full_name).on(:name).with_message("Enter a full name") }
  it { is_expected.to validate_presence_of(:email).on(:email).with_message("Enter an email address") }
  it { is_expected.to validate_presence_of(:delivery_partner_id).on(:delivery_partner_id).with_message("Choose a delivery partner") }

  describe ".save" do
    context "valid params" do
      before do
        expect(DeliveryPartnerProfile).to receive(:create_delivery_partner_user).with(
          params[:full_name],
          params[:email],
          delivery_partner,
        ).and_return(true)
      end

      it "should create delivery partner user" do
        expect(form.save).to be true
      end
    end

    context "invalid params" do
      let(:params) { {} }

      it "should not create delivery partner user" do
        expect(form.save).to be false
      end
    end
  end
end
