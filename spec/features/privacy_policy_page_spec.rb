# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Privacy policy page", type: :feature, js: true, rutabaga: false do
  let!(:privacy_policy) do
    create :privacy_policy
    PrivacyPolicy::Publish.call
  end

  scenario "Privacy policy is accessible" do
    given_i_am_on_the_privacy_policy_page
    then_the_page_is_accessible
  end

  scenario "Visiting the Privacy policy" do
    given_i_am_on_the_start_page
    when_i_view_privacy_policy_from_the_start_page
    then_i_am_on_the_privacy_policy_page
  end
end
