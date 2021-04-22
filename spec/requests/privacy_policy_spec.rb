# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Privacy policy", type: :request do
  let!(:privacy_policy) { create :privacy_policy }

  describe "GET /privacy_policy" do
    it "should show the privacy policy" do
      get privacy_policy_path

      expect(response).to render_template :show
      expect(response.body).to include Nokogiri.parse(privacy_policy.html).content
    end
  end
end
