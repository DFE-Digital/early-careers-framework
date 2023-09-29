# frozen_string_literal: true

RSpec.describe SupplierUserForm, type: :model do
  let(:lead_provider) { create(:lead_provider) }
  let(:params) { { full_name: "Test 1", email: "test@example.com", supplier: lead_provider.id } }

  subject(:form) { described_class.new(params) }

  it { is_expected.to validate_presence_of(:supplier).on(:supplier).with_message("Select one") }
  it { is_expected.to validate_presence_of(:full_name).on(:details).with_message("Enter a name") }
  it { is_expected.to validate_presence_of(:email).on(:details).with_message("Enter email") }

  describe ".save!" do
    context "valid params" do
      before do
        expect(LeadProviderProfile).to receive(:create_lead_provider_user).with(
          params[:full_name],
          params[:email],
          lead_provider,
          Rails.application.routes.url_helpers.root_url(
            host: Rails.application.config.domain,
            **UTMService.email(:new_lead_provider),
          ),
        ).and_return(true)
      end

      it "should create lead provider user" do
        expect(form.valid?(:supplier)).to be true
        expect(form.valid?(:details)).to be true
        expect(form.save!).to be true
      end
    end

    context "validate already created lead provider profile" do
      it "should not create lead provider user" do
        LeadProviderProfile.create_lead_provider_user(params[:full_name], params[:email], lead_provider, "https://test.com")

        expect(form.valid?(:supplier)).to be true
        expect(form.valid?(:details)).to be false
        expect(form.errors[:email]).to eql(["There is already a user with this email address"])
      end
    end

    context "invalid params" do
      let(:params) { {} }

      it "should not create lead provider user" do
        expect(form.valid?(:supplier)).to be false
        expect(form.valid?(:details)).to be false
      end
    end
  end
end
