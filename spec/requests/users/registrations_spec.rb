require "rails_helper"

RSpec.describe "Users::Registrations", type: :request do
  describe "GET /users/sign_up" do
    it "renders the correct template" do
      get "/users/sign_up"
      expect(response).to render_template(:new)
    end
  end

  describe "POST /users" do
    let(:email) { "firstname@digital.education.gov.uk" }

    let(:user_params) do
      { user: { email: email, first_name: "firstname", last_name: "lastname" } }
    end

    let(:user) { User.find_by_email(email) }

    let(:flash_message) do
      "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
    end

    it "creates the user" do
      post "/users", params: user_params
      expect(user).to be_truthy
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq flash_message
    end
  end
end
