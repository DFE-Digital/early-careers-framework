# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Privacy policy page", type: :feature, js: true, rutabaga: false do
  before do
    given_a_privacy_policy_has_been_published
  end

  scenario "Privacy policy is accessible" do
    given_i_am_on_the_privacy_policy_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Privacy policy page"
  end

  scenario "Visiting the Privacy policy" do
    given_i_am_on_the_start_page
    when_i_view_the_privacy_policy
    then_i_am_on_the_privacy_policy_page
  end

private

  def given_a_privacy_policy_has_been_published
    create :privacy_policy
    PrivacyPolicy::Publish.call
  end

  def when_i_view_the_privacy_policy
    start_page = Pages::StartPage.loaded
    start_page.view_privacy_policy
  end
end
