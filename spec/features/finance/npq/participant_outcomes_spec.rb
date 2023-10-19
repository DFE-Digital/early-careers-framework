# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Search participant data - participant outcomes", type: :feature do
  describe "NPQ user" do
    let(:participant_declaration) { create(:npq_participant_declaration) }
    let(:participant_outcome) { create(:participant_outcome, :passed, :successfully_sent_to_qualified_teachers_api, participant_declaration:) }
    let(:user) { participant_declaration.user }

    context "Passed outcome exists" do
      scenario "Displaying the correct data" do
        given_i_am_logged_in_as_a_finance_user
        and_an_user_with_declarations_and_outcomes
        when_i_visit_the_search_participant_data_page
        then_i_see("ParticipantProfile::NPQ")
        and_i_see("Declaration Outcomes: Passed and recorded")
        and_i_see("Passed")
      end
    end

    context "Passed but unsuccessfully recorded outcome exists" do
      let(:passed_but_unsuccessfully_recorded_outcome) { create(:participant_outcome, :passed, :unsuccessfully_sent_to_qualified_teachers_api, participant_declaration:) }

      scenario "Displaying the correct data" do
        given_i_am_logged_in_as_a_finance_user
        and_an_user_with_declarations_and_outcomes
        and_a_passed_but_unsuccessfully_recorded_outcome
        when_i_visit_the_search_participant_data_page
        then_i_see("ParticipantProfile::NPQ")
        and_i_see("Declaration Outcomes: Passed but not recorded")
        and_i_see("NO. CONTACT THE DIGITAL SERVICE TEAM")
        and_i_see("Resend")
      end
    end

    context "Passed but not recorded outcome exists" do
      let(:passed_but_not_recorded_outcome) { create(:participant_outcome, :passed, :not_sent_to_qualified_teachers_api, participant_declaration:) }

      scenario "Displaying the correct data" do
        given_i_am_logged_in_as_a_finance_user
        and_an_user_with_declarations_and_outcomes
        and_a_passed_but_not_recorded_outcome
        when_i_visit_the_search_participant_data_page
        then_i_see("ParticipantProfile::NPQ")
        and_i_see("Declaration Outcomes: Passed")
        and_i_see("N/A")
        and_i_see("Pending")
      end
    end

    context "Failed but unsuccessfully recorded outcome exists" do
      let(:failed_but_unsuccessfully_recorded_outcome) { create(:participant_outcome, :failed, :unsuccessfully_sent_to_qualified_teachers_api, participant_declaration:) }

      scenario "Displaying the correct data" do
        given_i_am_logged_in_as_a_finance_user
        and_an_user_with_declarations_and_outcomes
        and_a_failed_but_unsuccessfully_recorded_outcome
        when_i_visit_the_search_participant_data_page
        then_i_see("ParticipantProfile::NPQ")
        and_i_see("Declaration Outcomes: Failed but not recorded")
        and_i_see("NO. CONTACT THE DIGITAL SERVICE TEAM")
        and_i_see("Resend")
      end
    end

    context "Failed but not recorded outcome exists" do
      let(:failed_but_not_recorded_outcome) { create(:participant_outcome, :failed, :not_sent_to_qualified_teachers_api, participant_declaration:) }

      scenario "Displaying the correct data" do
        given_i_am_logged_in_as_a_finance_user
        and_an_user_with_declarations_and_outcomes
        and_a_failed_but_not_recorded_outcome
        when_i_visit_the_search_participant_data_page
        then_i_see("ParticipantProfile::NPQ")
        and_i_see("Declaration Outcomes: Failed")
        and_i_see("N/A")
        and_i_see("Pending")
      end
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

  def and_an_user_with_declarations_and_outcomes
    participant_declaration
    participant_outcome
  end

  def and_a_passed_but_unsuccessfully_recorded_outcome
    passed_but_unsuccessfully_recorded_outcome
  end

  def and_a_passed_but_not_recorded_outcome
    passed_but_not_recorded_outcome
  end

  def and_a_failed_but_unsuccessfully_recorded_outcome
    failed_but_unsuccessfully_recorded_outcome
  end

  def and_a_failed_but_not_recorded_outcome
    failed_but_not_recorded_outcome
  end
end
