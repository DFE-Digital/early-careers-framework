# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Confirmations", type: :request do
  let(:confirmation_token) { "soC7rF8i_BgYdUxafFcP" }

  let!(:user) do
    create(:user, confirmed_at: nil, confirmation_token: confirmation_token)
  end

  describe "GET /users/confirmation" do
    it "confirms the account" do
      get "/users/confirmation?confirmation_token=#{confirmation_token}"
      expect(user.reload.confirmed?).to be true
      expect(response).to render_template(:confirmed)
    end
  end
end
