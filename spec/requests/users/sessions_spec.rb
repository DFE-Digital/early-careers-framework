# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /users/sign_in" do
    it "renders the sign in page" do
      get "/users/sign_in"

      expect(response).to render_template(:new)
    end

    context "when already signed in" do
      before { sign_in user }

      it "redirects to the dashboard" do
        get "/users/sign_in"

        expect(response).to redirect_to "/dashboard"
      end
    end
  end

  describe "POST /users/sign_in" do
    let(:login_url_regex) { /http:\/\/localhost:3000\/users\/confirm_sign_in\?login_token=.*/ }

    before do
      mail = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
      allow(UserMailer).to receive(:sign_in_email).and_return(mail)
    end

    context "when email matches a user" do
      it "renders the login_email_sent template" do
        post "/users/sign_in", params: { user: { email: user.email } }
        expect(response).to render_template(:login_email_sent)
      end

      it "sends a log_in email request to User Mailer" do
        expect(UserMailer).to receive(:sign_in_email).with(user, login_url_regex)
        post "/users/sign_in", params: { user: { email: user.email } }
      end
    end

    context "when email doesn't match any user" do
      let(:email) { Faker::Internet.email }
      it "renders the email_not_found template" do
        post "/users/sign_in", params: { user: { email: email } }
        expect(response).to redirect_to(registrations_account_not_found_path)
      end

      it "does not send a log in email" do
        expect(UserMailer).not_to receive(:sign_in_email)
        post "/users/sign_in", params: { user: { email: email } }
      end
    end
  end

  describe "GET /users/confirm_sign_in" do
    it "renders the redirect_from_magic_link template" do
      get "/users/confirm_sign_in?login_token=#{user.login_token}"
      expect(assigns(:login_token)).to eq(user.login_token)
      expect(response).to render_template(:redirect_from_magic_link)
    end

    it "redirects to sign in when the token doesn't match" do
      get "/users/confirm_sign_in?login_token=aaaaaaaaaa"

      expect(response).to redirect_to "/users/sign_in"
      expect(flash[:alert]).to eq "There was an error while logging you in. Please enter your email again."
    end

    context "when the token has expired" do
      before { user.update!(login_token_valid_until: 1.hour.ago) }

      it "redirects to sign in" do
        get "/users/confirm_sign_in?login_token=#{user.login_token}"

        expect(response).to redirect_to "/users/sign_in"
        expect(flash[:alert]).to eq "There was an error while logging you in. Please enter your email again."
      end
    end

    context "when already signed in" do
      before { sign_in user }

      it "redirects to the dashboard" do
        get "/users/confirm_sign_in?login_token=aaaaaaaaaa"

        expect(response).to redirect_to "/dashboard"
      end
    end
  end

  describe "POST /users/sign_in_with_token" do
    context "when user is an ECT" do
      let(:user) { create(:user, :early_career_teacher) }

      it "redirects to dashboard on successful login" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when user is an induction coordinator" do
      let(:user) { create(:user, :induction_coordinator) }

      it "redirects to dashboard on successful login" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when user is a lead provider" do
      let(:user) { create(:user, :lead_provider) }

      it "redirects to dashboard on successful login" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when user is an admin" do
      let(:user) { create(:user, :admin) }

      it "redirects to sign_in page" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        expect(response).to redirect_to(admin_suppliers_path)
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
