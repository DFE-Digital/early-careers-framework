# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin delivery partner users" do
  before do
    given_a_delivery_partner_exists
    and_i_am_signed_in_as_an_admin
  end

  scenario "Add new user" do
    when_i_visit_admin_delivery_partner_users_page
    then_i_see("Delivery partners")

    when_i_click_on_add_a_new_user
    then_i_see("Add a new delivery partner user")
    and_i_choose("Delivery partner", with: @delivery_partner.name)
    and_i_fill_in("Full name", with: "Joe Blogs")
    and_i_fill_in("Email", with: "joe@example.com")
    and_i_click_on("Add user")

    then_i_see("Delivery partners")
    and_i_see("Delivery partner user successfully added")
    and_i_see("Joe Blogs")
    and_i_see("joe@example.com")
    and_i_see(@delivery_partner.name)
  end

  scenario "Edit a user" do
    given_a_delivery_partner_user_exists
    and_a_second_delivery_partner_exists
    when_i_visit_admin_delivery_partner_users_page
    then_i_see("Delivery partners")
    and_i_see(@delivery_partner_user.full_name)
    and_i_see(@delivery_partner_user.email)

    when_i_click_on(@delivery_partner_user.delivery_partners.first.name)
    then_i_see("Edit user details")
    and_i_choose("Delivery partner", with: @delivery_partner2.name)
    and_i_fill_in("Full name", with: "Joe Blogs")
    and_i_fill_in("Email", with: "joe@example.com")
    and_i_click_on("Save")

    then_i_see("Delivery partners")
    and_i_see("Changes saved successfully")
    and_i_see("Joe Blogs")
    and_i_see("joe@example.com")
    and_i_see(@delivery_partner2.name)
  end

  scenario "Delete a user" do
    given_a_delivery_partner_user_exists
    when_i_visit_admin_delivery_partner_users_page
    then_i_see("Delivery partners")
    and_i_see(@delivery_partner_user.full_name)
    and_i_see(@delivery_partner_user.email)

    when_i_click_on(@delivery_partner_user.delivery_partners.first.name)
    then_i_see("Edit user details")
    and_i_click_on("Delete")

    then_i_see("Do you want to delete this user?")
    and_i_see(@delivery_partner_user.full_name)
    and_i_click_on("Delete")

    then_i_see("Delivery partners")
    and_i_see("Delivery partner user deleted")
    and_i_should_not_see("Joe Blogs")
    and_i_should_not_see("joe@example.com")
  end

  def given_a_delivery_partner_exists
    @delivery_partner = create(:delivery_partner, name: "First Partner")
  end

  def and_a_second_delivery_partner_exists
    @delivery_partner2 = create(:delivery_partner, name: "Second Partner")
  end

  def when_i_visit_admin_delivery_partner_users_page
    visit("/admin/delivery-partners/users")
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

  def given_a_delivery_partner_user_exists
    @delivery_partner_user = create(:user, :delivery_partner)
  end
end
