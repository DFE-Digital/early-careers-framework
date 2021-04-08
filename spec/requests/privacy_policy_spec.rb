# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Privacy policy", type: :request do
  describe "GET /privacy_policy" do
    it "should show the privacy policy" do
      get privacy_policy_path

      expect(response).to render_template :show
      expect(response.body).to include("How we look after your personal data")
    end
  end
end
