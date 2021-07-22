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
    let(:login_url_regex) { /http:\/\/www\.example\.com\/users\/confirm_sign_in\?login_token=.*/ }
    let(:token_expiry_regex) { /\d\d:\d\d/ }

    before do
      allow(UserMailer).to receive(:sign_in_email).and_call_original
    end

    it "renders the login_email_sent template regardless of email match" do
      post "/users/sign_in", params: { user: { email: Faker::Internet.email } }
      expect(response).to render_template(:login_email_sent)
    end

    context "when email case-insensitively matches a user" do
      def randomize_case(string)
        string.chars.map { |char| char.send(%i[upcase downcase].sample) }.join
      end

      it "sends a log_in email request to User Mailer" do
        expect(UserMailer).to receive(:sign_in_email).with(
          hash_including(
            user: user,
            url: login_url_regex,
            token_expiry: token_expiry_regex,
          ),
        )
        post "/users/sign_in", params: { user: { email: randomize_case(user.email) } }
      end
    end

    context "when email doesn't match any user" do
      let(:email) { Faker::Internet.email }
      it "renders the login_email_sent template to prevent exposing information about user accounts" do
        post "/users/sign_in", params: { user: { email: email } }
        expect(response).to render_template(:login_email_sent)
      end

      it "does not send a log in email" do
        expect(UserMailer).not_to receive(:sign_in_email)
        post "/users/sign_in", params: { user: { email: email } }
      end
    end
  end

  describe "Valid mock login" do
    before do
      user.update!(email: test_email)
      allow(Rails).to receive(:env).and_return ActiveSupport::EnvironmentInquirer.new(environment.to_s)
    end

    context "admin email" do
      let(:test_email) { "admin@example.com" }

      context "using a non-production enviromment" do
        let(:environment) { :sandbox }

        it "redirects to the dashboard" do
          post "/users/sign_in", params: { user: { email: test_email } }
          expect(response).to redirect_to "/dashboard"
        end
      end

      context "using a production environment" do
        let(:environment) { :production }

        it "renders the login_email_sent template" do
          post "/users/sign_in", params: { user: { email: test_email } }
          expect(response).to render_template(:login_email_sent)
        end
      end
    end
  end

  describe "Invalid mock logins" do
    let(:environment) { :sandbox }

    before do
      allow(Rails).to receive(:env).and_return ActiveSupport::EnvironmentInquirer.new(environment.to_s)
    end

    context "unknown whitelisted email" do
      let(:test_email) { "not-in-the-database@example.com" }

      it "renders the login_email_sent template" do
        post "/users/sign_in", params: { user: { email: test_email } }
        expect(response).to render_template(:login_email_sent) # falls back to prod behaviour
      end
    end

    context "email domain not in the whitelist" do
      let(:test_email) { "admin@some.other.example.com" }

      context "using a non-production enviromment" do
        it "renders the login_email_sent template" do
          post "/users/sign_in", params: { user: { email: test_email } }
          expect(response).to render_template(:login_email_sent) # falls back to prod behaviour
        end
      end
    end
  end

  describe "GET /users/confirm_sign_in" do
    it "renders the redirect_from_magic_link template" do
      get "/users/confirm_sign_in?login_token=#{user.login_token}"
      expect(assigns(:login_token)).to eq(user.login_token)
      expect(response).to render_template(:redirect_from_magic_link)
    end

    it "redirects to link invalid when the token doesn't match" do
      get "/users/confirm_sign_in?login_token=aaaaaaaaaa"

      expect(response).to redirect_to "/users/link-invalid"
    end

    context "when the token has expired" do
      before { user.update!(login_token_valid_until: 1.hour.ago) }

      it "redirects to link invalid" do
        get "/users/confirm_sign_in?login_token=#{user.login_token}"

        expect(response).to redirect_to "/users/link-invalid"
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
      let(:school) { user.schools.first }

      it "redirects to correct dashboard" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        expect(response).to redirect_to(advisory_schools_choose_programme_path(school_id: school.slug))
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

      it "redirects to correct dashboard" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        expect(response).to redirect_to(admin_schools_path)
      end
    end

    context "when user is a finance user" do
      let(:user) { create(:user, :finance) }

      it "redirects to correct dashboard" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        expect(response).to redirect_to(finance_lead_providers_path)
      end
    end

    context "when the login_token has expired" do
      before { user.update(login_token_valid_until: 2.days.ago) }

      it "redirects to link invalid page" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        expect(response).to redirect_to(users_link_invalid_path)
      end
    end
  end
end
