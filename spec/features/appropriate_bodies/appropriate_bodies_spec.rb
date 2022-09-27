# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Appropriate body choose organisations page", type: :feature do
  scenario "User with one appropriate body" do
    given_user_with_one_appropriate_body_exists
    and_i_am_logged_in_as_appropriate_body_user

    when_i_visit_the_appropriate_bodies_page

    then_i_see("Participants")
    and_i_see(@appropriate_body_profile1.appropriate_body.name)
  end

  scenario "User with multiple appropriate bodies" do
    given_user_with_multiple_appropriate_body_exists
    and_i_am_logged_in_as_appropriate_body_user

    when_i_visit_the_appropriate_bodies_page

    then_i_see("What organisation do you want to view?")
    and_i_see_multiple_appropriate_bodies

    when_i_choose(@appropriate_body_profile2.appropriate_body.name)
    and_i_click_on("Continue")

    then_i_see("Participants")
    and_i_see(@appropriate_body_profile2.appropriate_body.name)
  end

  def given_user_with_one_appropriate_body_exists
    @appropriate_body_user = create(:user)
    @appropriate_body_profile1 = create(:appropriate_body_profile, user: @appropriate_body_user)
  end

  def given_user_with_multiple_appropriate_body_exists
    @appropriate_body_user = create(:user)
    @appropriate_body_profile1 = create(:appropriate_body_profile, user: @appropriate_body_user)
    @appropriate_body_profile2 = create(:appropriate_body_profile, user: @appropriate_body_user)
    @appropriate_body_profile3 = create(:appropriate_body_profile, user: @appropriate_body_user)
  end

  def and_i_am_logged_in_as_appropriate_body_user
    sign_in_as(@appropriate_body_user)
  end

  def when_i_visit_the_appropriate_bodies_page
    visit("/appropriate-bodies")
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  alias_method :and_i_see, :then_i_see

  def and_i_see_multiple_appropriate_bodies
    expect(page).to have_content(@appropriate_body_profile1.appropriate_body.name)
    expect(page).to have_content(@appropriate_body_profile2.appropriate_body.name)
    expect(page).to have_content(@appropriate_body_profile3.appropriate_body.name)
  end

  def when_i_choose(string)
    page.choose string
  end

  def when_i_click_on(string)
    page.click_on(string)
  end

  alias_method :and_i_click_on, :when_i_click_on
end
