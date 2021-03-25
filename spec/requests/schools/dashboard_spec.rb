# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Schools::Dashboard", type: :request do
  before do
    user = create(:user, :induction_coordinator)
    sign_in user
  end

  describe "GET /schools" do
    it "should render the dashboard" do
      get "/schools"

      expect(response).to render_template("schools/dashboard/show")
    end
  end
end
