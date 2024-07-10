# frozen_string_literal: true

require "rails_helper"
require_relative "../training_dashboard/manage_training_steps"

RSpec.describe "Induction coordinator requests lead provider change for acedemic year", js: true, mid_cohort: true do
  include ManageTrainingSteps

  scenario "SIT makes support query to change lead provider" do
    given_there_is_a_school_that_has_chosen_fip_for_two_consecutive_years_and_partnered
    and_i_am_signed_in_as_an_induction_coordinator
    and_there_is_a_choice_of_lead_providers
    when_i_visit_manage_training_dashboard
    click_on(Cohort.previous.start_year)
    click_on("Change lead provider", visible: false)
    then_i_see_the_intro_step
    then_i_choose_yes_on_the_start_step
    then_i_choose_a_new_lead_provider
    then_i_am_asked_to_check_my_answers
    then_i_change_the_lead_provider
    then_i_am_asked_to_check_my_changes
    click_on "Accept and send request"
    then_i_see_confirmation_that_the_request_has_been_sent
    and_a_support_query_has_been_created
  end

  def and_there_is_a_choice_of_lead_providers
    create(:lead_provider, name: "Lead Provider 1")
    create(:lead_provider, name: "Lead Provider 2")
  end

  def then_i_see_the_intro_step
    expect(page).to have_content("How to change your lead provider for the #{academic_year} academic year")
    expect(page).to have_content("If you contacted the current and new lead provider more than 2 weeks ago, and the change has still not been made, contact us.")
    click_on("contact us")
  end

  def then_i_choose_yes_on_the_start_step
    expect(page).to have_content("Have you confirmed this change with the current and new lead providers?")
    click_on "Continue"
    expect(page).to have_content("Select yes if you have confirmed this change with the current and new lead providers")
    choose "Yes"
    click_on "Continue"
  end

  def then_i_choose_a_new_lead_provider
    expect(page).to have_content("Who is the new lead provider?")
    click_on "Continue"
    expect(page).to have_content("Select who the new lead provider is")
    choose "Lead Provider 1"
    click_on "Continue"
  end

  def then_i_am_asked_to_check_my_answers
    expect(page).to have_content("Check your answers before you request the change")
    expect(page).to have_content("Change request details")
    expect(page).to have_content("Induction tutor name #{@school.induction_coordinators.first.full_name}")
    expect(page).to have_content("Induction tutor email address #{@school.induction_coordinators.first.email}")
    expect(page).to have_content(@school.name)
    expect(page).to have_content("Academic year #{academic_year}")
    expect(page).to have_content("Current lead provider #{@lead_provider.name}")
    expect(page).to have_content("New lead provider Lead Provider 1")
  end

  def then_i_change_the_lead_provider
    click_on "Change lead provider"
    expect(page).to have_content("Who is the new lead provider?")
    choose "Lead Provider 2"
    click_on "Continue"
  end

  def then_i_am_asked_to_check_my_changes
    expect(page).to have_content("Check your answers before you request the change")
    expect(page).to have_content("Change request details")
    expect(page).to have_content("New lead provider Lead Provider 2")
  end

  def then_i_see_confirmation_that_the_request_has_been_sent
    expect(page).to have_content("Your change request has been submitted")
  end

  def and_a_support_query_has_been_created
    expect(SupportQuery.count).to eq(1)
    expect(SupportQuery.last.subject).to eq("change-cohort-lead-provider")
  end

  def academic_year
    start_year = Cohort.previous.start_year
    "#{start_year} to #{start_year + 1}"
  end
end
