# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Administrators::Administrators", type: :request do
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }
  let(:new_user) { User.find_by(email: email) }
  let(:admin_user) { create(:user, :admin) }
  let(:admin_user_two) { create(:user, :admin, full_name: "Emma Dow", email: "emma-dow@example.com") }
  let(:admin_profile_two) { admin_user_two.admin_profile }

  before do
    sign_in admin_user
    admin_user_two
  end

  describe "GET /admin/administrators" do
    it "renders the index template" do
      get "/admin/administrators"
      expect(response).to render_template("admin/administrators/administrators/index")
    end
  end

  describe "GET /admin/administrators/new" do
    it "renders the new template" do
      get "/admin/administrators/new"
      expect(response).to render_template("admin/administrators/administrators/new")
    end

    it "prefills fields when passed the continue parameter" do
      given_i_have_previously_submitted_values(name, email)

      get "/admin/administrators/new?continue=true"

      expect(response.body).to include(CGI.escapeHTML(email))
      expect(response.body).to include(CGI.escapeHTML(name))
    end

    it "clears fields when not passed the continue parameter" do
      given_i_have_previously_submitted_values(name, email)

      get "/admin/administrators/new"

      expect(response.body).not_to include(CGI.escapeHTML(email))
      expect(response.body).not_to include(CGI.escapeHTML(name))
    end
  end

  describe "POST /admin/administrators/new/confirm" do
    it "renders the confirmation template" do
      given_i_have_previously_submitted_values(name, email)

      expect(response).to render_template("admin/administrators/administrators/confirm")
    end

    it "shows an error when a field is blank" do
      post "/admin/administrators/new/confirm", params: { user: {
        full_name: name,
        email: "",
      } }
      expect(response).to render_template("admin/administrators/administrators/new")
      expect(response.body).to include("Enter an email")
    end
  end

  describe "POST /admin/administrators" do
    it "creates a new user" do
      expect { create_new_user }.to change { User.count }.by 1
    end

    it "creates a new admin profile" do
      expect { create_new_user }.to change { AdminProfile.count }.by 1
    end

    it "makes the new user an admin" do
      given_a_user_is_created

      expect(new_user.admin?).to be true
    end

    it "renders a success message" do
      given_a_user_is_created

      expect(response).to redirect_to("/admin/administrators")
      expect(flash[:success]).to(
        eql({
          title: "Success",
          heading: "User added",
          content: "They have been sent an email to sign in",
        }),
      )
    end

    it "sends new admin an account created email" do
      url = "http://www.example.com/users/sign_in"
      allow(AdminMailer).to receive(:account_created_email).and_call_original

      given_a_user_is_created

      expect(AdminMailer).to have_received(:account_created_email).with(new_user, url)
    end
  end

  let(:admin_profile) { create(:admin_profile) }
  let(:admin) { admin_profile.user }

  describe "GET /admin/administrators/:id/edit" do
    it "renders the edit template" do
      get "/admin/administrators/#{admin.id}/edit"

      expect(response).to render_template("admin/administrators/administrators/edit")
    end
  end

  describe "PATCH /admin/administrators/:id" do
    it "updates the user and redirects to administrators page" do
      patch "/admin/administrators/#{admin.id}", params: {
        user: { email: email },
      }

      expect(admin.reload.email).to eq email
      expect(response).to redirect_to(:admin_administrators)
      expect(flash[:notice]).to eq "Changes saved successfully"
    end

    context "when the user params are invalid" do
      it "renders error messages" do
        patch "/admin/administrators/#{admin.id}", params: {
          user: { email: nil },
        }

        expect(response.body).to include("Enter an email")
        expect(response).to render_template("admin/administrators/administrators/edit")
      end
    end
  end

  describe "DELETE /admin/administrators/:id/" do
    it "marks the lead_provider profile as deleted" do
      delete "/admin/administrators/#{admin_user_two.id}"

      admin_profile_two.reload
      admin_user_two.reload
      expect(admin_profile_two.discarded?).to be true
      expect(admin_user_two.discarded?).to be true
    end

    it "redirects to the lead_provider users index page" do
      delete "/admin/administrators/#{admin_user_two.id}"

      expect(response).to redirect_to("/admin/administrators")
      expect(response.body).not_to include(CGI.escapeHTML(admin_user_two.full_name))
    end

    it "does not allow deleting the current logged in admin" do
      expect { delete "/admin/administrators/#{admin_user.id}" }.to raise_error Pundit::NotAuthorizedError

      admin_profile.reload
      admin_user.reload
      expect(admin_profile.discarded?).to be false
      expect(admin_user.discarded?).to be false
    end

    describe "when an audited action", versioning: true do
      let(:current_admin) { admin_user }

      before do
        delete "/admin/administrators/#{admin_user_two.id}"
      end

      include_examples "audits changes"
    end
  end

private

  def given_i_have_previously_submitted_values(name, email)
    post "/admin/administrators/new/confirm", params: { user: {
      full_name: name,
      email: email,
    } }
  end

  def create_new_user
    post "/admin/administrators", params: { user: {
      full_name: name,
      email: email,
    } }
  end

  alias_method :given_a_user_is_created, :create_new_user
end
