# frozen_string_literal: true

require "rails_helper"

RSpec.feature "User research pages", js: true, rutabaga: false do
  scenario "Viewing the page as a mentor" do
    when_i_visit the_mentor_research_page
    then_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Mentor user research page")
  end

  scenario "Viewing the page as an ECT" do
    when_i_visit the_ect_research_page
    then_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("ECT user research page")
  end

  scenario "Viewing the page when the sessions are fully booked" do
    given_feature_flag_is_active :user_research_full_booked

    when_i_visit the_ect_research_page
    then_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Fully booked user research page")
  end

private

  def the_ect_research_page
    "/pages/user-research"
  end

  def the_mentor_research_page
    "/pages/user-research?mentor=true"
  end
end
