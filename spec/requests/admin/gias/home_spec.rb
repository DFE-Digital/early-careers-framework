# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Gias::Home", type: :request do
  let(:admin_user) { create(:user, :admin) }

  before do
    sign_in admin_user
  end

  describe "GET /admin/gias" do
    it "renders the index template" do
      get "/admin/gias"
      expect(response).to render_template("admin/gias/home/index")
      expect(assigns(:schools_to_add_count)).to eq(0)
      expect(assigns(:schools_to_close_count)).to eq(0)
      expect(assigns(:schools_with_changes_count)).to eq(0)
    end
  end
end
