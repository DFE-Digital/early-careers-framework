# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Administrators::Administrators", type: :request do
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email }

  before do
    user = create(:user, :admin)
    sign_in user
  end

  describe "#show" do
    it "renders the confirmation template" do
      get "/admin/administrators/new/confirm", params: {
        full_name: name,
        email: email,
      }

      expect(response).to render_template("admin/administrators/confirm_administrator/show")
    end
  end
end
