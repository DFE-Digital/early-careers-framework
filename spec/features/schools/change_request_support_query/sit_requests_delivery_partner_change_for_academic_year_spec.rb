# frozen_string_literal: true

require "rails_helper"
require_relative "../training_dashboard/manage_training_steps"

RSpec.describe "Induction coordinator requests delivery partner change for academic year", js: true, mid_cohort: true do
  include ManageTrainingSteps

  scenario "SIT makes support query to change delivery partner" do
    given_there_is_a_school_that_has_chosen_fip_for_two_consecutive_years_and_partnered
    and_i_am_signed_in_as_an_induction_coordinator
    and_there_is_a_choice_of_delivery_partners
    when_i_visit_manage_training_dashboard
    click_on(Cohort.previous.start_year)
    click_on("Change delivery partner", visible: false)
    then_i_see_the_intro_step
    then_i_choose_yes_on_the_start_step
    then_i_choose_a_new_delivery_partner
    then_i_am_asked_to_check_my_answers
    then_i_change_the_delivery_partner
    then_i_am_asked_to_check_my_changes
    click_on "Accept and send request"
    then_i_see_confirmation_that_the_request_has_been_sent
    and_a_support_query_has_been_created
  end

  def and_there_is_a_choice_of_delivery_partners
    create(:provider_relationship,
           cohort: @school_cohort.cohort,
           lead_provider: @lead_provider,
           delivery_partner: create(:delivery_partner, name: "Delivery Partner 1"))
    create(:provider_relationship,
           cohort: @school_cohort.cohort,
           lead_provider: @lead_provider,
           delivery_partner: create(:delivery_partner, name: "Delivery Partner 2"))
  end

  def then_i_see_the_intro_step
    expect(page).to have_content("How to change your delivery partner for the #{academic_year} academic year")
    expect(page).to have_content("If you contacted your lead provider more than 2 weeks ago, and the change has still not been made, contact us.")
    click_on("contact us")
  end

  def then_i_choose_yes_on_the_start_step
    expect(page).to have_content("Have you confirmed this change with your lead provider?")
    click_on "Continue"
    expect(page).to have_content("Select yes if you have confirmed this change with your lead provider")
    choose "No"
    click_on "Continue"
    expect(page).to have_content("You need to contact your lead provider")
    page.go_back
    choose "Yes"
    click_on "Continue"
  end

  def then_i_choose_a_new_delivery_partner
    expect(page).to have_content("Who is the new delivery partner?")
    click_on "Continue"
    expect(page).to have_content("Select who the new delivery partner is")
    choose "Delivery Partner 1"
    click_on "Continue"
  end

  def then_i_am_asked_to_check_my_answers
    expect(page).to have_content("Check your answers before you request the change")
    expect(page).to have_content("Change request details")
    expect(page).to have_content("Induction tutor name #{@school.induction_coordinators.first.full_name}")
    expect(page).to have_content("Induction tutor email address #{@school.induction_coordinators.first.email}")
    expect(page).to have_content(@school.name)
    expect(page).to have_content("Academic year #{academic_year}")
    expect(page).to have_content("Current delivery partner #{@delivery_partner.name}")
    expect(page).to have_content("New delivery partner Delivery Partner 1")
  end

  def then_i_change_the_delivery_partner
    click_on "Change delivery partner"
    expect(page).to have_content("Who is the new delivery partner?")
    choose "Delivery Partner 2"
    click_on "Continue"
  end

  def then_i_am_asked_to_check_my_changes
    expect(page).to have_content("Check your answers before you request the change")
    expect(page).to have_content("Change request details")
    expect(page).to have_content("New delivery partner Delivery Partner 2")
  end

  def then_i_see_confirmation_that_the_request_has_been_sent
    expect(page).to have_content("Your change request has been submitted")
  end

  def and_a_support_query_has_been_created
    expect(SupportQuery.count).to eq(1)
    expect(SupportQuery.last.subject).to eq("change-cohort-delivery-partner")
  end

  def academic_year
    start_year = Cohort.previous.start_year
    "#{start_year} to #{start_year + 1}"
  end
end
