# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  let(:user) { create(:user) }

  describe "POST /users/sign_in" do
    context "when sign in email has been sent" do
      it "renders the correct template" do
        post "/users/sign_in", params: { user: { email: user.email } }
        expect(response).to render_template(:login_email_sent)
      end
    end

    context "when email doesn't match any user" do
      let(:email) { Faker::Internet.email }
      it "renders the correct template" do
        post "/users/sign_in", params: { user: { email: email } }
        expect(response).to render_template(:email_not_found)
      end
    end
  end

  describe "GET /users/confirm_sign_in" do
    it "renders the correct template" do
      get "/users/confirm_sign_in?login_token=#{user.login_token}"
      expect(assigns(:login_token)).to eq(user.login_token)
      expect(response).to render_template(:redirect_from_magic_link)
    end
  end

  describe "POST /users/sign_in_with_token" do
    it "redirects to dashboard on successful login" do
      post "/users/sign_in_with_token", params: { login_token: user.login_token }
      expect(response).to redirect_to(dashboard_path)
    end

    context "when user is an admin" do
      let(:user) { create(:user, :admin) }

      it "redirects to sign_in page" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context "when the login_token has expired" do
      before { user.update(login_token_valid_until: 2.days.ago) }

      it "redirects to sign_in page" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
