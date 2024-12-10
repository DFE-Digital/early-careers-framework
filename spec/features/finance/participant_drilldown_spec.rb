# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users participant drilldown", type: :feature do
  describe "ECT user" do
    let(:ect_user)        { ect_declaration.user }
    let(:ect_profile)     { ect_declaration.participant_profile }
    let(:ect_declaration) { create(:ect_participant_declaration) }
    let(:ect_identity)    { ect_profile.participant_identity }

    before do
      given_i_am_logged_in_as_a_finance_user
      and_an_ect_user_with_profile_and_declarations
      when_i_visit_the_finance_homepage
      and_i_click_on("Search participant data")
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

  def and_i_do_not_see(string)
    expect(page).to_not have_content(string)
  end

  def when_i_fill_in(selector, with:)
    page.fill_in selector, with:
  end

  def and_an_ect_user_with_profile_and_declarations
    ect_user
    ect_profile
    ect_declaration
  end
end
