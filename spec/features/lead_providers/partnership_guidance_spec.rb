# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Lead Provider landing pages", type: :feature, js: true do
  scenario "Learning how to manage partnerships" do
    given_i_am_on_the_lead_provider_landing_page
    and_the_page_is_accessible
    when_i_click_the_link_to_the_guidance_page
    then_i_am_on_the_lead_providers_partnership_guide_page
    and_the_page_is_accessible
  end

  context "when 'programme_type_changes_2025' is disabled" do
    before { FeatureFlag.deactivate("programme_type_changes_2025") }

    scenario "Learning how to manage partnerships" do
      given_i_am_on_the_lead_provider_landing_page
      when_i_click_the_link_to_the_guidance_page
      then_i_should_see_core_induction_programme
    end
  end

  context "when 'programme_type_changes_2025' is enabled" do
    before { FeatureFlag.activate("programme_type_changes_2025") }

    scenario "Learning how to manage partnerships" do
      given_i_am_on_the_lead_provider_landing_page
      when_i_click_the_link_to_the_guidance_page
      then_i_should_see_school_led
    end
  end

private

  def when_i_click_the_link_to_the_guidance_page
    @lead_providers_page.learn_to_manage_ecf_partnerships
  end

  def given_i_am_on_the_lead_provider_landing_page
    @lead_providers_page = Pages::LeadProviderLandingPage.load
    expect(@lead_providers_page).to be_displayed
  end

  def then_i_am_on_the_lead_providers_partnership_guide_page
    @guidance_page = Pages::LeadProviderPartnershipGuidancePage.new
    expect(@guidance_page).to be_displayed
  end

  def then_i_should_see_core_induction_programme
    @guidance_page = Pages::LeadProviderPartnershipGuidancePage.new
    expect(@guidance_page).to have_content("They can only use the accredited materials (core induction programme).")
  end

  def then_i_should_see_school_led
    @guidance_page = Pages::LeadProviderPartnershipGuidancePage.new
    expect(@guidance_page).to have_content("They can only use the accredited materials (school led).")
  end
end
