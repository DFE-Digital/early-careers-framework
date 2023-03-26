# frozen_string_literal: true

RSpec.describe AppropriateBodies::UpdateUserForm, type: :model do
  let(:user) { create(:user, full_name: "Example Name", email: "madeup@example.com") }
  let(:appropriate_body_1) { create(:appropriate_body_local_authority) }
  let(:appropriate_body_2) { create(:appropriate_body_local_authority) }

  let(:appropriate_body_profile) { create(:appropriate_body_profile, user:, appropriate_body: appropriate_body_1) }

  let(:params) { { full_name: "Test 1", email: "test@example.com", appropriate_body_id: appropriate_body_2.id } }

  subject(:form) { described_class.new(appropriate_body_profile:) }

  it { is_expected.to validate_presence_of(:full_name).on(:name).with_message("Enter a full name") }
  it { is_expected.to validate_presence_of(:email).on(:email).with_message("Enter an email address") }
  it { is_expected.to validate_presence_of(:appropriate_body_id).on(:appropriate_body_id).with_message("Choose an appropriate body") }

  describe ".update" do
    context "valid params" do
      it "should change appropriate body user details" do
        appropriate_body_profile.reload
        expect(appropriate_body_profile.user.full_name).to eql("Example Name")
        expect(appropriate_body_profile.user.email).to eql("madeup@example.com")
        expect(appropriate_body_profile.appropriate_body).to eql(appropriate_body_1)

        expect(form.update(params)).to be true

        appropriate_body_profile.reload
        expect(appropriate_body_profile.user.full_name).to eql("Test 1")
        expect(appropriate_body_profile.user.email).to eql("test@example.com")
        expect(appropriate_body_profile.appropriate_body).to eql(appropriate_body_2)
      end
    end

    context "invalid params" do
      let(:params) { { full_name: nil, email: nil, appropriate_body_id: nil } }

      it "should not create appropriate body user" do
        expect(form.update(params)).to be false
      end
    end
  end
end
