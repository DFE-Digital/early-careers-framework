# frozen_string_literal: true

RSpec.describe DeliveryPartners::UpdateUserForm, type: :model do
  let(:delivery_partner_user) { create(:user, :delivery_partner) }
  let(:delivery_partner) { create(:delivery_partner) }
  let(:params) { { full_name: "Test 1", email: "test@example.com", delivery_partner_id: delivery_partner.id } }

  subject(:form) { described_class.new(delivery_partner_user) }

  it { is_expected.to validate_presence_of(:full_name).on(:name).with_message("Enter a full name") }
  it { is_expected.to validate_presence_of(:email).on(:email).with_message("Enter an email") }
  it { is_expected.to validate_presence_of(:delivery_partner_id).on(:delivery_partner_id).with_message("Choose a delivery partner") }

  describe ".update" do
    context "valid params" do
      before do
        expect(delivery_partner_user).to receive(:update!).with(
          full_name: params[:full_name],
          email: params[:email],
        ).and_return(true)

        expect(delivery_partner_user.delivery_partner_profile).to receive(:update!).with(
          delivery_partner:,
        ).and_return(true)
      end

      it "should create delivery partner user" do
        expect(form.update(params)).to be true
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
