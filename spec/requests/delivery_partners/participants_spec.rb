# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DeliveryPartners::Participants", type: :request do
  let(:user) { create(:user, :delivery_partner) }
  let(:delivery_partner) { user.delivery_partners.first }

  before do
    sign_in user
  end

  describe "GET delivery-partners/participants" do
    it "renders the index participants template" do
      get "/delivery-partners/#{delivery_partner.id}/participants"
      expect(response).to render_template "delivery_partners/participants/index"
    end
  end

  describe "Unauthorised user" do
    let(:user) { create(:user) }

    it "raises not authorised error" do
      expect {
        get "/delivery-partners"
      }.to raise_error Pundit::NotAuthorizedError
    end
  end
end
