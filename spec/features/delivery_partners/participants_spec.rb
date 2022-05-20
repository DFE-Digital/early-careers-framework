# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Delivery partner users participants", type: :feature do
  let(:school) { create(:school) }
  let(:school_cohort) { create(:school_cohort, school: school) }
  let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort, training_status: "withdrawn") }

  let(:delivery_partner_user) { create(:user, :delivery_partner) }
  let(:partnership) { create(:partnership, school: school, delivery_partner: delivery_partner_user.delivery_partner_profile.delivery_partner) }

  let!(:prev_cohort_year) { create(:cohort, start_year: 2020) }

  before do
    given_i_am_logged_in_as_a_delivery_partner_user
    and_participant_profile_exists
    when_i_visit_the_delivery_partners_participants_page
  end

  scenario "Visit participants page" do
    then_i_see("Participants")
    and_i_see_participant_details
  end

  context "Search query" do
    scenario "None existing search term" do
      when_i_fill_in("query", with: "MADE UP XXX123")
      and_i_click_on("Search")
      and_i_do_not_see_participant_details
    end

    scenario "Search name" do
      when_i_fill_in("query", with: participant_profile.user.full_name)
      and_i_click_on("Search")
      and_i_see_participant_details
    end

    scenario "Search email" do
      when_i_fill_in("query", with: participant_profile.user.email)
      and_i_click_on("Search")
      and_i_see_participant_details
    end

    scenario "Search TRN" do
      when_i_fill_in("query", with: participant_profile.teacher_profile.trn)
      and_i_click_on("Search")
      and_i_see_participant_details
    end
  end

  context "Filter role" do
    scenario "None existing role" do
      when_i_choose("role", with: "Mentor")
      and_i_click_on("Search")
      and_i_do_not_see_participant_details
    end

    scenario "Existing role" do
      when_i_choose("role", with: "Early career teacher")
      and_i_click_on("Search")
      and_i_see_participant_details
    end
  end

  context "Filter academic year" do
    scenario "None existing year" do
      when_i_choose("academic_year", with: 2020)
      and_i_click_on("Search")
      and_i_do_not_see_participant_details
    end

    scenario "Existing year" do
      when_i_choose("academic_year", with: participant_profile.cohort.start_year)
      and_i_click_on("Search")
      and_i_see_participant_details
    end
  end

  context "Filter status" do
    let(:participant_profile) { create(:ect_participant_profile, school_cohort: school_cohort, training_status: "withdrawn") }

    scenario "None existing status" do
      when_i_choose("status", with: "Checking QTS")
      and_i_click_on("Search")
      and_i_do_not_see_participant_details
    end

    scenario "Existing status" do
      when_i_choose("status", with: "No longer being trained")
      and_i_click_on("Search")
      and_i_see_participant_details
    end
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

  def and_i_do_not_see_participant_details
    expect(page).not_to have_content(participant_profile.user.full_name)
    expect(page).not_to have_content(participant_profile.user.email)
  end

  def when_i_fill_in(selector, with:)
    page.fill_in selector, with: with
  end

  def when_i_choose(selector, with:)
    page.select with, from: selector
  end

  def and_i_click_on(string)
    page.click_on(string)
  end
end
