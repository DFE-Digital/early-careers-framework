# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /users/sign_out" do
    it "logs out the user and redirects to the homepage" do
      # visit authenticated route
      get "/dashboard"
      expect(controller.current_user).to eq user

      get "/users/sign_out"

      expect(response).to redirect_to(root_path)
      expect(controller.current_user).to be_nil
      expect(flash[:notice]).to eq "Signed out successfully."
    end
  end
end
