# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Sandbox landing page", type: :feature, js: true, rutabaga: false do
  scenario "Sandbox landing page is accessible" do
    given_i_am_on_the_sandbox_landing_page
    then_the_page_is_accessible
  end

  scenario "Continuing as a Lead Provider" do
    given_i_am_on_the_sandbox_landing_page
    when_i_continue_as_an_ecf_training_provider_from_the_sandbox_landing_page
    then_i_am_on_the_lead_provider_landing_page
  end
end
