# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Choose roles page", type: :feature do
  scenario "User with one role" do
    given_a_user_exists
    and_has_appropriate_body_role
    and_i_am_logged_in_as_user

    when_i_visit_the_choose_roles_page

    then_i_see("Participants")
    and_i_see(@user.appropriate_bodies.first.name)
  end

  scenario "User with multiple roles" do
    given_a_user_exists
    and_has_delivery_partner_role
    and_has_appropriate_body_role
    and_i_am_logged_in_as_user

    when_i_visit_the_choose_roles_page
    then_i_see("What role do you want to view?")
    and_i_see("Delivery partner")
    and_i_see("Appropriate body")

    when_i_choose("Appropriate body")
    and_i_click_on("Continue")

    then_i_see("Participants")
    and_i_see(@user.appropriate_bodies.first.name)
  end

  def given_a_user_exists
    @user = create(:user)
  end

  def and_has_delivery_partner_role
    create(:delivery_partner_profile, user: @user)
  end

  def and_has_appropriate_body_role
    create(:appropriate_body_profile, user: @user)
  end

  def and_i_am_logged_in_as_user
    sign_in_as(@user)
  end

  def when_i_visit_the_choose_roles_page
    visit("/choose-role")
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  alias_method :and_i_see, :then_i_see

  def when_i_choose(string)
    page.choose string
  end

  def when_i_click_on(string)
    page.click_on(string)
  end

  alias_method :and_i_click_on, :when_i_click_on
end
