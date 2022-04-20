# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Sandbox landing page", type: :feature, js: true, rutabaga: false do
  scenario "Visiting the Lead Providers sandbox landing page" do
    given_i_am_on_the_sandbox_landing_page
    then_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Sandbox landing page"
  end

  scenario "Continuing as a Lead Provider" do
    given_i_am_on_the_sandbox_landing_page
    when_i_continue_as_an_ecf_training_provider
    then_i_am_on_the_lead_provider_landing_page
  end

private

  def given_i_am_on_the_sandbox_landing_page
    sandbox_landing_page = Pages::SandboxLandingPage.new
    sandbox_landing_page.load
    sandbox_landing_page.is_on_page?
  end

  def when_i_continue_as_an_ecf_training_provider
    sandbox_landing_page = Pages::SandboxLandingPage.new
    sandbox_landing_page.continue_as_an_ecf_training_provider
  end

  def then_i_am_on_the_lead_provider_landing_page
    lead_provider_landing_page = Pages::LeadProviderLandingPage.new
    lead_provider_landing_page.is_on_page?
  end
end
