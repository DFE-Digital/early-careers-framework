# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users participant drilldown", type: :feature do
  let(:ect_user) { create(:user, :early_career_teacher) }
  let(:ect_profile) { ect_user.early_career_teacher_profile }
  let(:ect_declaration) { create(:ect_participant_declaration, user: ect_user, participant_profile: ect_profile) }

  let(:npq_user) { create(:user, :npq) }
  let(:npq_profile) { npq_user.npq_profiles[0] }
  let(:npq_declaration) { create(:npq_participant_declaration, user: npq_user, participant_profile: npq_profile) }
  let(:npq_application) { create(:npq_application, participant_identity: npq_identity) }
  let(:npq_identity) { create(:participant_identity, :npq_origin, user: npq_user) }

  scenario "viewing ECT user" do
    given_i_am_logged_in_as_a_finance_user
    and_an_ect_user_with_profile_and_declarations
    when_i_visit_the_finance_homepage
    and_i_click_on("Participant drilldown")
    then_i_see("Search participants")

    when_i_fill_in("query", with: ect_user.id)
    and_i_click_on("Search")
    then_i_see("ParticipantProfile::ECT")
    and_i_see("Declaration type#{ect_declaration.declaration_type}")
  end

  def when_i_visit_the_finance_homepage
    visit("/finance/manage-cpd-contracts")
  end

  def and_i_click_on(string)
    page.click_on(string)
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_see(string)
    then_i_see(string)
  end

  def when_i_fill_in(selector, with:)
    page.fill_in selector, with: with
  end

  def and_an_ect_user_with_profile_and_declarations
    ect_user
    ect_profile
    ect_declaration
  end

  def and_an_npq_user_with_application_and_profile_and_declarations
    npq_user
    npq_profile
    npq_identity
    npq_declaration
    npq_application
  end

  scenario "viewing NPQ user" do
    given_i_am_logged_in_as_a_finance_user
    and_an_npq_user_with_application_and_profile_and_declarations
    when_i_visit_the_finance_homepage
    and_i_click_on("Participant drilldown")
    then_i_see("Search participants")

    when_i_fill_in("query", with: npq_user.id)
    and_i_click_on("Search")
    then_i_see("Identity 1")
    and_i_see("ParticipantProfile::NPQ")
    and_i_see("Declaration type#{npq_declaration.declaration_type}")
  end
end
