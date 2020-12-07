require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /email_confirmation" do
    it "renders the correct template" do
      get "/email_confirmation?login_token=#{user.login_token}"
      expect(assigns(:login_token)).to eq(user.login_token)
      expect(response).to render_template(:redirect_from_magic_link)
    end
  end

  describe "POST /sign_in_with_token" do
    it "redirects to dashboard on successful login" do
      post "/sign_in_with_token", params: { login_token: user.login_token }
      expect(response).to redirect_to(dashboard_path)
    end

    context "when the login_token has expired" do
      before { user.update(login_token_valid_until: 2.days.ago) }

      it "redirects to sign_in page" do
        post "/sign_in_with_token", params: { login_token: user.login_token }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
