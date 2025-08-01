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
        follow_redirect!

        expect(response).to redirect_to "/dashboard"
      end
    end
  end

  describe "POST /users/sign_in" do
    let(:login_url_regex) { /http:\/\/www\.example\.com\/users\/confirm_sign_in\?login_token=.*/ }
    let(:token_expiry_regex) { /^\d{1,2}\s\w+\s\d{4},\s+\d{1,2}:\d{2}\s(PM|AM)+$/ }

    before do
      allow(UserMailer).to receive(:with).and_call_original
    end

    it "renders the login_email_sent template regardless of email match" do
      post "/users/sign_in", params: { user: { email: Faker::Internet.email } }
      expect(response).to render_template(:login_email_sent)
    end

    context "when participant identity email used" do
      let!(:participant_identity) { create(:participant_identity, user:, email: "id2@example.com") }

      it "sends login email to participant identity email" do
        expect(UserMailer).to receive(:with).with(
          hash_including(
            email: "id2@example.com",
            full_name: user.full_name,
            url: login_url_regex,
            token_expiry: token_expiry_regex,
          ),
        )
        post "/users/sign_in", params: { user: { email: "id2@example.com" } }
      end
    end

    context "when email case-insensitively matches a user" do
      def randomize_case(string)
        string.chars.map { |char| char.send(%i[upcase downcase].sample) }.join
      end

      it "sends a log_in email request to User Mailer" do
        expect(UserMailer).to receive(:with).with(
          hash_including(
            email: user.email,
            full_name: user.full_name,
            url: login_url_regex,
            token_expiry: token_expiry_regex,
          ),
        ).and_call_original
        post "/users/sign_in", params: { user: { email: randomize_case(user.email) } }
      end
    end

    context "when email doesn't match any user" do
      let(:email) { Faker::Internet.email }
      it "renders the login_email_sent template to prevent exposing information about user accounts" do
        post "/users/sign_in", params: { user: { email: } }
        expect(response).to render_template(:login_email_sent)
      end

      it "does not send a log in email" do
        expect(UserMailer).not_to receive(:sign_in_email)
        post "/users/sign_in", params: { user: { email: } }
      end
    end

    context "when a blank email is inputted" do
      email = ""
      it "renders the new template" do
        post "/users/sign_in", params: { user: { email: } }
        expect(response).to render_template(:new)
      end
    end

    context "when an invalid email is inputted" do
      emails = %w[invalid@email,com email invalid@email @email.com]
      emails.each do |email|
        it "renders the new template" do
          post "/users/sign_in", params: { user: { email: } }
          expect(response).to render_template(:new)
        end
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
          follow_redirect!
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

      context "using a non-production environment" do
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

    context "when no token is provided" do
      before do
        user.update!(login_token_valid_until: nil)
        user.update!(login_token: nil)
      end

      it "redirects to link invalid" do
        get "/users/confirm_sign_in"

        expect(response).to redirect_to "/users/link-invalid"
      end
    end

    context "when already signed in" do
      before { sign_in user }

      it "redirects to the dashboard" do
        get "/users/confirm_sign_in?login_token=aaaaaaaaaa"
        follow_redirect!

        expect(response).to redirect_to "/dashboard"
      end
    end
  end

  describe "POST /users/sign_in_with_token" do
    context "when user is an ECT" do
      let(:user) { create(:ect_participant_profile).user }
      let(:school) { user.teacher_profile.early_career_teacher_profile.school }

      it "redirects to participant validation on successful login" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        follow_redirect!
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when user is an induction coordinator" do
      let(:user) { create(:user, :induction_coordinator) }
      let(:school) { user.schools.first }
      let!(:cohort) { create :cohort, :current }

      it "redirects to correct dashboard" do
        inside_registration_window(cohort:) do
          post "/users/sign_in_with_token", params: { login_token: user.login_token }
          follow_redirect!
          expect(response).to redirect_to(schools_choose_programme_path(school_id: school.slug, cohort_id: cohort.start_year))
        end
      end
    end

    context "when user is an induction coordinator and a non-validated mentor" do
      let(:user) { create(:user, :induction_coordinator) }
      let(:school) { user.schools.first }
      let(:teacher_profile) { create :teacher_profile, user: }
      let!(:participant_profile) { create :mentor_participant_profile, teacher_profile:, cohort: }
      let!(:cohort) { Cohort.active_registration_cohort }

      it "redirects to correct dashboard" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        # it will treat multiple school roles as one role
        follow_redirect!
        expect(response).to redirect_to(schools_choose_programme_path(school_id: school.slug, cohort_id: cohort.start_year))
      end
    end

    context "when user is a non-validated mentor" do
      let(:user) { create(:user) }
      let(:teacher_profile) { create :teacher_profile, user: }
      let!(:participant_profile) { create :mentor_participant_profile, teacher_profile: }
      let!(:cohort) { participant_profile.cohort }

      it "redirects to correct dashboard" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        follow_redirect!
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when user is a lead provider" do
      let(:user) { create(:user, :lead_provider) }

      it "redirects to dashboard on successful login" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        follow_redirect!
        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when user is an admin" do
      let(:user) { create(:user, :admin) }

      it "redirects to correct dashboard" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        follow_redirect!
        expect(response).to redirect_to(admin_path)
      end
    end

    context "when user is a finance user" do
      let(:user) { create(:user, :finance) }

      it "redirects to correct dashboard" do
        post "/users/sign_in_with_token", params: { login_token: user.login_token }
        follow_redirect!
        expect(response).to redirect_to(finance_landing_page_path)
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

  describe "Session restore error" do
    let(:session) { ActiveRecord::SessionStore::Session.last }

    # A marshalled object "MadeUp", this class does not exist
    let(:bad_data) { "BAh7CUkiDnJldHVybl90bwY6BkVGSSI3aHR0cDovL2xvY2FsaG9zdDozMDAw\nL2ZpbmFuY2UvbWFuYWdlLWNwZC1jb250cmFjdHMGOwBUSSIQX2NzcmZfdG9r\nZW4GOwBGSSIwU2ZFdHZ6c096RmUwMmk5RTFsd1ZkdG5PejVTb3VzdHhoRDZX\nakZwcmxNbwY7AEZJIhl3YXJkZW4udXNlci51c2VyLmtleQY7AFRbB1sGSSIp\nZWEzODM0NTItYzNiMC00ZGMyLWIwMzMtOTUwNzhhYjYwYmE2BjsAVDBJIgl0\nZXN0BjsARm86K0ZpbmFuY2U6OkxhbmRpbmdQYWdlQ29udHJvbGxlcjo6TWFk\nZVVwAA==\n" }

    it "resets session and redirect to login" do
      # Login normally to create session
      sign_in user
      get "/users/sign_in"
      follow_redirect!
      expect(response).to redirect_to "/dashboard"

      # Inject bad data into session store
      ActiveRecord::SessionStore::Session.where(id: session.id).update_all(data: bad_data)

      get "/dashboard"
      follow_redirect! if response.status == 302

      expect(request.path).to eq "/users/sign_in"
    end
  end
end
