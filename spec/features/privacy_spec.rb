# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Privacy", type: :feature, js: true, rutabaga: false do
  scenario "Visiting the Privacy Policy page" do
    given_a_privacy_policy_has_been_created
    when_i_visit_the_home_page
    and_i_click_privacy_link
    then_i_am_on_the_privacy_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Privacy page"
  end

private

  def given_a_privacy_policy_has_been_created
    create :privacy_policy
    PrivacyPolicy::Publish.call
  end

  def when_i_visit_the_home_page
    visit "/"
  end

  def and_i_click_privacy_link
    click_on "Privacy"
  end

  def then_i_am_on_the_privacy_page
    expect(page).to have_content "Who we are and why we process personal data"
    expect(current_path).to eq("/privacy-policy")
  end
end
