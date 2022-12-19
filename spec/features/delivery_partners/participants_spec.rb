# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Delivery partner users participants", type: :feature do
  let(:school) { create(:school) }
  let(:school_cohort) { create(:school_cohort, school:) }
  let(:participant_profile) { create(:ect_participant_profile, school_cohort:, training_status: "withdrawn") }

  let(:delivery_partner_user) { create(:user, :delivery_partner) }
  let(:delivery_partner) { delivery_partner_user.delivery_partners.first }
  let(:partnership) do
    create(
      :partnership,
      school:,
      delivery_partner:,
      challenged_at: nil,
      challenge_reason: nil,
      pending: false,
    )
  end

  let(:induction_programme) { create(:induction_programme, :fip, partnership:, school_cohort:) }
  let!(:induction_record) { create(:induction_record, participant_profile:, induction_programme:) }

  let!(:prev_cohort_year) { Cohort[2020] || create(:cohort, start_year: 2020) }

  before do
    given_i_am_logged_in_as_a_delivery_partner_user
    and_participant_profile_exists
    when_i_visit_the_delivery_partners_participants_page
  end

  scenario "Visit participants page" do
    then_i_see("Participants")
    and_i_see_participant_details
  end

  scenario "Download participants CSV" do
    then_i_see("Participants")
    when_i_click_on("Download (csv)")
    and_i_see_participant_details_csv_export
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
    let(:participant_profile) { create(:ect_participant_profile, school_cohort:, training_status: "withdrawn") }

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
    visit("/delivery-partners/#{delivery_partner.id}/participants")
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
    page.fill_in selector, with:
  end

  def when_i_choose(selector, with:)
    page.select with, from: selector
  end

  def and_i_click_on(string)
    page.click_on(string)
  end

  def when_i_click_on(string)
    page.click_on(string)
  end

  def and_i_see_participant_details_csv_export
    data = CSV.parse(page.body).transpose
    expect(data[0]).to eq(["full_name", participant_profile.user.full_name])
    expect(data[1]).to eq(["email_address", participant_profile.user.email])
  end
end
