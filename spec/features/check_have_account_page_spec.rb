# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Check you have an account page", type: :feature, js: true, rutabaga: false do
  scenario "Check you have an account page is accessible" do
    given_i_am_on_the_check_account_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Check you have an account page"
  end

  scenario "Visiting the Check you have an account page" do
    given_i_am_on_the_start_page
    and_i_start_now_from_start_page
    and_i_find_out_how_to_get_access_from_sign_in_page
    then_i_am_on_the_check_account_page
  end
end
