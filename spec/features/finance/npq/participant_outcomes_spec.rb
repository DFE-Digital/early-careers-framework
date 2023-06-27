# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Search participant data - participant outcomes", type: :feature do
  describe "NPQ user" do
    let(:participant_declaration) { create(:npq_participant_declaration) }
    let(:participant_outcome) { create :participant_outcome, :passed, participant_declaration: }
    let(:user) { participant_declaration.user }

    scenario "passed outcome exists" do
      given_i_am_logged_in_as_a_finance_user
      and_an_user_with_declarations_and_outcomes
      when_i_visit_the_search_participant_data_page
      then_i_see("ParticipantProfile::NPQ")
      and_i_see("Declaration Outcomes")
      and_i_see("passed")
    end
  end

  def when_i_visit_the_search_participant_data_page
    visit("/finance/participants/#{user.id}")
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_see(string)
    then_i_see(string)
  end

  def and_an_user_with_declarations_and_outcomes
    participant_declaration
    participant_outcome
  end
end
