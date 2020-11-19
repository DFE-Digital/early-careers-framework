require "rails_helper"

RSpec.feature "View pages", type: :feature do
  scenario "Navigate to home" do
    visit "/pages/home"

    expect(page).to have_text("Lorem")
  end

  scenario "Navigate to supplier dashboard" do
    visit "/supplier_dashboard"

    expect(page).to have_text("Admin dashboard for Upwards Learning")
  end
end
