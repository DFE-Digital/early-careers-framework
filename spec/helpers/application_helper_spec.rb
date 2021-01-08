# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  let(:user) { create(:user) }
  let!(:admin) { create(:admin_profile, user: user) }

  describe "#profile_dashboard_url" do
    it "returns the dashboard url for the user profile" do
      expect(helper.profile_dashboard_url(user)).to eq("http://test.host/admin_dashboard")
    end
  end
end
