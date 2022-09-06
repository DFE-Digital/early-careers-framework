# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users participant drilldown", :with_default_schedules, type: :feature do
  describe "ECT user" do
    let(:ect_user)        { ect_declaration.user }
    let(:ect_profile)     { ect_declaration.participant_profile }
    let(:ect_declaration) { create(:ect_participant_declaration) }
    let(:ect_identity)    { ect_profile.participant_identity }

    before do
      given_i_am_logged_in_as_a_finance_user
      and_an_ect_user_with_profile_and_declarations
      when_i_visit_the_finance_homepage
      and_i_click_on("Participant drilldown")
      then_i_see("Search records")
    end

    scenario "search by ID" do
      when_i_fill_in("query", with: ect_user.id)
      and_i_click_on("Search")
      then_i_see("ParticipantProfile::ECT")
      and_i_see("Declaration type#{ect_declaration.declaration_type}")
    end

    scenario "search by external identifier" do
      when_i_fill_in("query", with: ect_identity.external_identifier)
      and_i_click_on("Search")
      then_i_see("ParticipantProfile::ECT")
      then_i_see(ect_user.id)
    end

    scenario "search by declaration ID" do
      when_i_fill_in("query", with: ect_declaration.id)
      and_i_click_on("Search")
      then_i_see("ParticipantProfile::ECT")
      then_i_see(ect_user.id)
      then_i_see(ect_declaration.id)
    end
  end

  describe "NPQ user" do
    let(:npq_declaration) { create(:npq_participant_declaration) }
    let(:npq_user) { npq_declaration.user }
    let(:npq_profile) { npq_declaration.participant_profile }
    let(:npq_application) { npq_profile.npq_application }
    let(:npq_identity) { npq_profile.participant_identity }

    before do
      given_i_am_logged_in_as_a_finance_user
      and_an_npq_user_with_application_and_profile_and_declarations
      when_i_visit_the_finance_homepage
      and_i_click_on("Participant drilldown")
      then_i_see("Search records")
    end

    scenario "search by ID" do
      when_i_fill_in("query", with: npq_user.id)
      and_i_click_on("Search")
      then_i_see("Identity 1")
      and_i_see("ParticipantProfile::NPQ")
      and_i_see("Declaration type#{npq_declaration.declaration_type}")
    end

    scenario "search by application ID" do
      when_i_fill_in("query", with: npq_application.id)
      and_i_click_on("Search")
      then_i_see("Identity 1")
      and_i_see("ParticipantProfile::NPQ")
      and_i_see("Declaration type#{npq_declaration.declaration_type}")
    end

    scenario "search by declaration ID" do
      when_i_fill_in("query", with: npq_declaration.id)
      and_i_click_on("Search")
      and_i_see("ParticipantProfile::NPQ")
      then_i_see(npq_user.id)
      then_i_see(npq_declaration.id)
    end
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
    page.fill_in selector, with:
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
end
