# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Maintenance banner", type: :request do
  describe "GET /maintenance_banners/dismiss" do
    it "sets a cookie to dismiss the maintenance banner" do
      get maintenance_banner_dismiss_path

      cookie_value = response.cookies["dismiss_maintenance_banner_until"]
      expect(cookie_value).to be_present
      expect(Time.zone.parse(cookie_value)).to be_within(1.second).of(1.week.from_now)
    end

    it "redirects back to the root path if no referer is present" do
      get maintenance_banner_dismiss_path
      expect(response).to redirect_to(root_path)
    end

    it "redirects back to the referer" do
      get maintenance_banner_dismiss_path, params: {}, headers: { "HTTP_REFERER" => "/previous/page" }

      expect(response).to redirect_to("/previous/page")
    end
  end
end
