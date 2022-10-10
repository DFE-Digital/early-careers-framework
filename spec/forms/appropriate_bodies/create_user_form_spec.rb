# frozen_string_literal: true

RSpec.describe AppropriateBodies::CreateUserForm, type: :model do
  let(:appropriate_body) { create(:appropriate_body_local_authority) }
  let(:params) { { full_name: "Test 1", email: "test@example.com", appropriate_body_id: appropriate_body.id } }

  subject(:form) { described_class.new(params) }

  it { is_expected.to validate_presence_of(:full_name).on(:name).with_message("Enter a full name") }
  it { is_expected.to validate_presence_of(:email).on(:email).with_message("Enter an email") }
  it { is_expected.to validate_presence_of(:appropriate_body_id).on(:appropriate_body_id).with_message("Choose an appropriate body") }

  describe ".save" do
    context "valid params" do
      before do
        expect(AppropriateBodyProfile).to receive(:create_appropriate_body_user).with(
          params[:full_name],
          params[:email],
          appropriate_body,
        ).and_return(true)
      end

      it "should create appropriate body user" do
        expect(form.save).to be true
      end
    end

    context "invalid params" do
      let(:params) { {} }

      it "should not create appropriate body user" do
        expect(form.save).to be false
      end
    end
  end
end
