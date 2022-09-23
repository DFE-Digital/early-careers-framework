# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Delivery partner choose organisations page", type: :feature do
  let(:delivery_partner_user) { create(:user) }
  let(:delivery_partner_profile1) { create(:delivery_partner_profile, user: delivery_partner_user) }
  let(:delivery_partner_profile2) { create(:delivery_partner_profile, user: delivery_partner_user) }
  let(:delivery_partner_profile3) { create(:delivery_partner_profile, user: delivery_partner_user) }

  scenario "User with one delivery partner" do
    given_user_with_one_delivery_partner_exists
    and_i_am_logged_in_as_delivery_partner_user

    when_i_visit_the_delivery_partners_page

    then_i_see("Participants")
    and_i_see(delivery_partner_profile1.delivery_partner.name)
  end

  scenario "User with multiple delivery partners" do
    given_user_with_multiple_delivery_partner_exists
    and_i_am_logged_in_as_delivery_partner_user

    when_i_visit_the_delivery_partners_page

    then_i_see("What organisation do you want to view?")
    and_i_see_multiple_delivery_partners

    when_i_choose(delivery_partner_profile2.delivery_partner.name)
    and_i_click_on("Continue")

    then_i_see("Participants")
    and_i_see(delivery_partner_profile2.delivery_partner.name)
  end

  def given_user_with_one_delivery_partner_exists
    delivery_partner_profile1
  end

  def given_user_with_multiple_delivery_partner_exists
    delivery_partner_profile1
    delivery_partner_profile2
    delivery_partner_profile3
  end

  def and_i_am_logged_in_as_delivery_partner_user
    sign_in_as(delivery_partner_user)
  end

  def when_i_visit_the_delivery_partners_page
    visit("/delivery-partners")
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  alias_method :and_i_see, :then_i_see

  def and_i_see_multiple_delivery_partners
    expect(page).to have_css(".govuk-radios__item", text: delivery_partner_profile1.delivery_partner.name)
    expect(page).to have_css(".govuk-radios__item", text: delivery_partner_profile2.delivery_partner.name)
    expect(page).to have_css(".govuk-radios__item", text: delivery_partner_profile3.delivery_partner.name)
  end

  def when_i_choose(string)
    page.choose string
  end

  def when_i_click_on(string)
    page.click_on(string)
  end

  alias_method :and_i_click_on, :when_i_click_on
end
