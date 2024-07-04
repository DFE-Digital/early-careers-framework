# frozen_string_literal: true

require "rails_helper"
require_relative "../../training_dashboard/manage_training_steps"

RSpec.describe "Induction coordinator requests lead provider change for a participant", js: true, mid_cohort: true do
  include ManageTrainingSteps

  scenario "SIT makes support query to change lead provider" do
    given_there_is_a_school_that_has_chosen_fip_and_partnered
    and_i_am_signed_in_as_an_induction_coordinator
    and_there_is_an_ect_in_the_active_registration_cohort
    and_there_is_a_choice_of_lead_providers
    when_i_visit_manage_training_dashboard
    click_on("Early career teachers")
    click_on(@participant_data[:full_name])
    click_on("Change Lead provider", visible: false)
    then_i_see_the_intro_step
    then_i_choose_yes_on_the_start_step
    then_i_add_an_alternative_email_for_the_participant
    then_i_choose_a_new_lead_provider
    then_i_am_asked_to_check_my_answers
    click_on "Accept and send request"
    then_i_see_confirmation_that_the_request_has_been_sent
  end

  def and_there_is_an_ect_in_the_active_registration_cohort
    set_participant_data
    user = create(:user, full_name: @participant_data[:full_name], email: @participant_data[:email])
    teacher_profile = create(:teacher_profile, user:, trn: @participant_data[:trn])
    schedule = create(:ecf_schedule, cohort: @cohort)
    participant_identity = create(:participant_identity, user:)
    participant_profile = create(:ect_participant_profile, teacher_profile:,
                                 participant_identity:,
                                 schedule:, school_cohort: @school_cohort,
                                 induction_start_date: Date.new(@cohort.start_year, 9, 1))

    create(:ecf_participant_validation_data, participant_profile:,
           full_name: @participant_data[:full_name], trn: @participant_data[:trn],
           date_of_birth: @participant_data[:date_of_birth])
    induction_programme = InductionProgramme.find_by(school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile:, induction_programme:)

    create(:ect_participant_declaration, participant_profile:,
           cpd_lead_provider: @lead_provider.cpd_lead_provider, state: :eligible)
    set_dqt_validation_result
  end

  def and_there_is_a_choice_of_lead_providers
    create(:lead_provider, name: "Lead Provider 1")
    create(:lead_provider, name: "Lead Provider 2")
  end

  def then_i_see_the_intro_step
    expect(page).to have_content("How to change the lead provider for #{@participant_data[:full_name]}")
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

  def then_i_add_an_alternative_email_for_the_participant
    expect(page).to have_content("Email #{@participant_data[:email]}")
    expect(page).to have_content("Is this the correct email for #{@participant_data[:full_name]}?")
    click_on "Continue"
    expect(page).to have_content("Select yes if this is the correct email address for the participant")
    choose "No"
    fill_in "email[email]", with: "different@example.com", visible: false
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
    expect(page).to have_content("Participant name #{@participant_data[:full_name]}")
    expect(page).to have_content(@school.name)
    expect(page).to have_content("Academic year #{@cohort.start_year}")
    expect(page).to have_content("Participant email address different@example.com")
    expect(page).to have_content("Current lead provider #{@lead_provider.name}")
    expect(page).to have_content("New lead provider Lead Provider 1")
  end

  def then_i_see_confirmation_that_the_request_has_been_sent
    expect(page).to have_content("Your change request has been submitted")
  end
end
