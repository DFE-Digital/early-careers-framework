# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  let(:admin_user) { create(:user, :admin) }

  describe "#profile_dashboard_url" do
    it "returns the dashboard url for the user profile" do
      expect(helper.profile_dashboard_url(admin_user)).to eq("http://test.host/admin/dashboard")
    end
  end
end
