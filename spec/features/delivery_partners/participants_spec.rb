# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Delivery partner users participants", type: :feature do
  let(:school) { create(:school) }
  let(:school_cohort) { create(:school_cohort, school: school) }
  let(:participant_profile) { create(:ecf_participant_profile, school_cohort: school_cohort) }

  let(:delivery_partner_user) { create(:user, :delivery_partner) }
  let(:partnership) { create(:partnership, school: school, delivery_partner: delivery_partner_user.delivery_partner_profile.delivery_partner) }

  scenario "Visit participants page" do
    given_i_am_logged_in_as_a_delivery_partner_user
    and_participant_profile_exists
    when_i_visit_the_delivery_partners_participants_page
    then_i_see("Participants")
    and_i_see_participant_details
  end

  def given_i_am_logged_in_as_a_delivery_partner_user
    sign_in_as(delivery_partner_user)
  end

  def and_participant_profile_exists
    participant_profile
    delivery_partner_user
    partnership
  end

  def when_i_visit_the_delivery_partners_participants_page
    visit("/delivery-partners/participants")
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_see_participant_details
    expect(page).to have_content(participant_profile.user.full_name)
    expect(page).to have_content(participant_profile.user.email)
  end
end
