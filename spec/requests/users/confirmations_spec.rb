# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Confirmations", type: :request do
  let(:confirmation_token) { "soC7rF8i_BgYdUxafFcP" }
  let(:school) { create(:school) }
  let(:induction_coordinator) { user.induction_coordinator_profile }

  let!(:user) do
    create(:user, :induction_coordinator, confirmed_at: nil, confirmation_token: confirmation_token)
  end

  describe "GET /users/confirmation" do
    before do
      school.induction_coordinator_profiles << induction_coordinator
    end

    it "confirms the account" do
      get "/users/confirmation?confirmation_token=#{confirmation_token}"
      expect(user.reload.confirmed?).to be true
      expect(response).to render_template(:confirmed)
    end

    it "notifies the school primary contact" do
      expect(UserMailer).to receive(:primary_contact_notification).with(user, school)

      get "/users/confirmation?confirmation_token=#{confirmation_token}"
    end
  end
end
