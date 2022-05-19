# frozen_string_literal: true

require "rails_helper"

RSpec.feature "User research pages", js: true, rutabaga: false do
  scenario "Viewing the page as a mentor" do
    given_i_am_on_the_user_research_page_with_mentor true
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Mentor user research page"
  end

  scenario "Viewing the page as an ECT" do
    given_i_am_on_the_user_research_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "ECT user research page"
  end

  scenario "Viewing the page when the sessions are fully booked" do
    given_i_am_on_the_user_research_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Fully booked user research page"
  end
end
