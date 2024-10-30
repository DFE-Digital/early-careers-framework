# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Maintenance banner" do
  before do
    FeatureFlag.activate(:maintenance_banner)
    stub_const("Banners::MaintenanceComponent::MAINTENANCE_WINDOW", 1.day.ago..1.day.from_now)
  end

  scenario "viewing the root path" do
    visit root_path
    expect(page).to have_text(/This service will be unavailable from/)
  end

  context "when disabled" do
    before { FeatureFlag.deactivate(:maintenance_banner) }

    scenario "viewing the root path" do
      visit root_path
      expect(page).not_to have_text(/This service will be unavailable from/)
    end
  end
end
