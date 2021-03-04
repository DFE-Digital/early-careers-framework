# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Administrators::Administrators", type: :request do
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }

  before do
    user = create(:user, :admin)
    sign_in user
  end

  describe "POST /admin/administrators/new/success" do
    it "creates a new user" do
      expect { create_new_user }.to change { User.count }.by 1
    end

    it "creates a new admin profile" do
      expect { create_new_user }.to change { AdminProfile.count }.by 1
    end

    it "confirms the new user" do
      given_a_user_is_created

      expect(new_user.confirmed?).to be true
    end

    it "makes the new user an admin" do
      given_a_user_is_created

      expect(new_user.admin?).to be true
    end

    it "renders a success message" do
      given_a_user_is_created

      expect(response).to render_template("admin/administrators/success/create")
    end
  end

private

  def create_new_user
    post "/admin/administrators/new/success", params: { user: {
      full_name: name,
      email: email,
    } }
  end

  alias_method :given_a_user_is_created, :create_new_user

  def new_user
    User.find_by(email: email)
  end
end
