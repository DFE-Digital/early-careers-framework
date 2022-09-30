# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin delivery partner users" do
  let!(:delivery_partner)     { create(:delivery_partner, name: "First Partner") }

  before do
    and_i_am_signed_in_as_an_admin
  end

  scenario "Add new user" do
    visit("/admin/delivery-partner-profiles")
    then_i_see("Delivery partners")

    click_on("Add a new user")

    then_i_see("Add a new delivery partner user")

    click_on("Add user")

    within "ul.govuk-error-summary__list" do
      expect(page).to have_link("Enter a full name", href: "#delivery-partner-profile-user-full-name-field-error")
      expect(page).to have_link("Enter an email", href: "#delivery-partner-profile-user-email-field-error")
      expect(page).to have_link("You must select a delivery partner.", href: "#delivery-partner-profile-delivery-partner-id-field-error")
    end

    select(delivery_partner.name, from: "Delivery partner")
    fill_in "Full name", with: "Joe Blogs"
    fill_in "Email", with: "joe@example.com"
    click_on "Add user"

    then_i_see("Delivery partners")
    and_i_see("Delivery partner user successfully added")
    and_i_see("Joe Blogs")
    and_i_see("joe@example.com")
    and_i_see(delivery_partner.name)
  end

  context "when a delivery partner user exist" do
    let!(:delivery_partner_user) { create(:user, :delivery_partner) }
    let!(:second_delivery_partner) { create(:delivery_partner, name: "Second Partner") }

    scenario "Edit a user" do
      visit("/admin/delivery-partner-profiles")
      then_i_see("Delivery partners")
      and_i_see(delivery_partner_user.full_name)
      and_i_see(delivery_partner_user.email)

      click_on(delivery_partner_user.full_name)
      then_i_see("Edit user details")
      select second_delivery_partner.name, from: "Delivery partner"
      fill_in "Full name", with: "Joe Blogs"
      fill_in "Email", with: "joe@example.com"
      click_on "Save"

      then_i_see("Delivery partners")
      and_i_see("Changes saved successfully")
      and_i_see("Joe Blogs")
      and_i_see("joe@example.com")
      and_i_see(second_delivery_partner.name)
    end

    scenario "Delete a user" do
      visit("/admin/delivery-partner-profiles")

      then_i_see("Delivery partners")
      and_i_see(delivery_partner_user.full_name)
      and_i_see(delivery_partner_user.email)

      click_on(delivery_partner_user.full_name)
      then_i_see("Edit user details")
      click_on("Delete")

      then_i_see("Do you want to delete this user?")
      and_i_see(delivery_partner_user.full_name)
      click_on("Delete")

      then_i_see("Delivery partners")
      and_i_see("Delivery partner user deleted")
      and_i_should_not_see("Joe Blogs")
      and_i_should_not_see("joe@example.com")
    end
  end

  def and_i_choose(selector, with:)
    select with, from: selector
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
end
