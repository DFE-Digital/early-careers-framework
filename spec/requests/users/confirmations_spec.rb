require "rails_helper"

RSpec.describe "Users::Confirmations", type: :request do
  let(:confirmation_token) { "soC7rF8i_BgYdUxafFcP" }

  let!(:user) do
    create(:user, confirmed_at: nil, confirmation_token: confirmation_token)
  end

  describe "GET /users/confirmation" do
    let(:flash_notice) { "Your email address has been successfully confirmed." }

    it "confirms the account" do
      get "/users/confirmation?confirmation_token=#{confirmation_token}"
      expect(user.reload.confirmed?).to be true
      expect(flash[:notice]).to eq flash_notice
      expect(response).to redirect_to(user_session_path)
    end
  end
end
