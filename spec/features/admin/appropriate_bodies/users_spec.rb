# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin appropriate body users", with_feature_flags: { appropriate_bodies: "active" } do
  before do
    given_a_appropriate_body_exists
    and_i_am_signed_in_as_an_admin
  end

  scenario "Add new user" do
    when_i_visit_admin_appropriate_body_users_page
    then_i_see("Appropriate bodies")

    when_i_click_on_add_a_new_user
    then_i_see("Add a new appropriate body user")
    and_i_choose("Appropriate body", with: @appropriate_body.name)
    and_i_fill_in("Full name", with: "Joe Blogs")
    and_i_fill_in("Email", with: "joe@example.com")
    and_i_click_on("Add user")

    then_i_see("Appropriate bodies")
    and_i_see("Appropriate body user successfully added")
    and_i_see("Joe Blogs")
    and_i_see("joe@example.com")
    and_i_see(@appropriate_body.name)
  end

  scenario "Edit a user" do
    given_a_appropriate_body_user_exists
    and_a_second_appropriate_body_exists
    when_i_visit_admin_appropriate_body_users_page
    then_i_see("Appropriate bodies")
    and_i_see(@appropriate_body_user.full_name)
    and_i_see(@appropriate_body_user.email)

    when_i_click_on(@appropriate_body_user.appropriate_bodies.first.name)
    then_i_see("Edit user details")
    and_i_choose("Appropriate body", with: @appropriate_body2.name)
    and_i_fill_in("Full name", with: "Joe Blogs")
    and_i_fill_in("Email", with: "joe@example.com")
    and_i_click_on("Save")

    then_i_see("Appropriate bodies")
    and_i_see("Changes saved successfully")
    and_i_see("Joe Blogs")
    and_i_see("joe@example.com")
    and_i_see(@appropriate_body2.name)
  end

  scenario "Delete a user" do
    given_a_appropriate_body_user_exists
    when_i_visit_admin_appropriate_body_users_page
    then_i_see("Appropriate bodies")
    and_i_see(@appropriate_body_user.full_name)
    and_i_see(@appropriate_body_user.email)

    when_i_click_on(@appropriate_body_user.appropriate_bodies.first.name)
    then_i_see("Edit user details")
    and_i_click_on("Delete")

    then_i_see("Do you want to delete this user?")
    and_i_see(@appropriate_body_user.full_name)
    and_i_click_on("Delete")

    then_i_see("Appropriate bodies")
    and_i_see("Appropriate body user deleted")
    and_i_should_not_see("Joe Blogs")
    and_i_should_not_see("joe@example.com")
  end

  def given_a_appropriate_body_exists
    @appropriate_body = create(:appropriate_body_local_authority, name: "First Partner")
  end

  def and_a_second_appropriate_body_exists
    @appropriate_body2 = create(:appropriate_body_local_authority, name: "Second Partner")
  end

  def when_i_visit_admin_appropriate_body_users_page
    visit("/admin/appropriate-bodies/users")
  end

  def when_i_click_on_add_a_new_user
    click_on("Add a new user")
  end

  def and_i_choose(selector, with:)
    page.select with, from: selector
  end

  def and_i_fill_in(selector, with:)
    page.fill_in selector, with:
  end

  def when_i_click_on(string)
    page.click_on(string)
  end

  def and_i_click_on(string)
    page.click_on(string)
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_should_not_see(string)
    expect(page).not_to have_content(string)
  end

  def given_a_appropriate_body_user_exists
    @appropriate_body_user = create(:user, :appropriate_body)
  end
end
