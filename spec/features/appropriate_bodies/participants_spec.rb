# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Appropriate body users participants", type: :feature do
  let(:appropriate_body_user) { create(:user, :appropriate_body) }
  let(:appropriate_body) { appropriate_body_user.appropriate_bodies.first }

  let(:participant_profile) { create :ect_participant_profile, training_status: "withdrawn" }
  let(:mentor_profile) { create :mentor_participant_profile, training_status: "withdrawn" }
  let(:lead_provider) { create(:lead_provider) }
  let(:delivery_partner) { create(:delivery_partner) }
  let(:school) { create(:school) }
  let(:school_cohort) { create(:school_cohort, school:) }
  let(:partnership) do
    create(
      :partnership,
      delivery_partner:,
      lead_provider:,
      challenged_at: nil,
      challenge_reason: nil,
      pending: false,
    )
  end
  let(:induction_programme) { create(:induction_programme, :fip, partnership:, school_cohort:) }
  let!(:induction_record) { create(:induction_record, participant_profile:, appropriate_body:, induction_programme:, training_status: "withdrawn") }
  let!(:mentor_induction_record) { create(:induction_record, participant_profile: mentor_profile, appropriate_body:, induction_programme:, training_status: "withdrawn") }

  let!(:prev_cohort_year) { create(:cohort, start_year: 2020) }

  before do
    given_i_am_logged_in_as_a_appropriate_body_user
    and_participant_profile_exists
    when_i_visit_the_appropriate_bodies_participants_page
  end

  scenario "Visit participants page" do
    then_i_see("Participants")
    and_i_see_participant_details
    and_i_do_not_see_mentor_details
  end

  scenario "Download participants CSV" do
    then_i_see("Participants")
    when_i_click_on("Download (csv)")
    and_i_see_participant_details_csv_export
    and_i_do_not_see_mentor_details_csv_export
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

    scenario "Search TRN" do
      when_i_fill_in("query", with: participant_profile.teacher_profile.trn)
      and_i_click_on("Search")
      and_i_see_participant_details
    end
  end

  context "Filter status" do
    let(:participant_profile) { create(:ect_participant_profile, school_cohort:) }
    let!(:induction_record) { create(:induction_record, participant_profile:, induction_programme:, appropriate_body:, training_status: "withdrawn") }

    scenario "None existing status" do
      when_i_choose("status", with: "Checking QTS")
      and_i_click_on("Search")
      and_i_do_not_see_participant_details
    end

    scenario "Existing status" do
      when_i_choose("status", with: "ECT not currently linked to you")
      and_i_click_on("Search")
      and_i_see_participant_details
    end
  end

  context "when there are newer induction records for a different appropriate body" do
    let!(:latest_induction_record) { create(:induction_record, participant_profile:, induction_programme:, training_status: "deferred") }

    scenario "Visit participants page" do
      then_i_see("Participants")
      and_i_see_participant_details
      and_i_do_not_see_newer_induction_record_details
    end
  end

private

  def given_i_am_logged_in_as_a_appropriate_body_user
    sign_in_as(appropriate_body_user)
  end

  def and_participant_profile_exists
    participant_profile
    appropriate_body_user
    partnership
  end

  def when_i_visit_the_appropriate_bodies_participants_page
    visit("/appropriate-bodies/#{appropriate_body.id}/participants")
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_see_participant_details
    expect(page).to have_content(participant_profile.user.full_name)
  end

  def and_i_do_not_see_participant_details
    expect(page).not_to have_content(participant_profile.user.full_name)
  end

  def and_i_do_not_see_mentor_details
    expect(page).not_to have_content(mentor_profile.user.full_name)
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
    expect(data[1]).to eq(["trn", participant_profile.teacher_profile.trn])
    expect(data[2]).to eq(["school_urn", induction_record.school&.urn])
    expect(data[3]).to eq(["status", "ECT not currently linked to you"])
    expect(data[4]).to eq(%w[induction_type FIP])
    expect(data[5]).to eq(["induction_tutor", induction_record.school.contact_email])
  end

  def and_i_do_not_see_mentor_details_csv_export
    expect(page.body).not_to include(mentor_profile.user.full_name)
  end

  def and_i_do_not_see_newer_induction_record_details
    expect(page).not_to have_content("particpant has deferred")
  end
end
