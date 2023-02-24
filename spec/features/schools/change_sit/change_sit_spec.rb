# frozen_string_literal: true

require "rails_helper"
require_relative "../../nominations/nominate_induction_tutor_steps"

RSpec.describe "Change a school induction tutor (SIT) as a SIT", js: true do
  include NominateInductionTutorSteps

  scenario "a SIT with one school assigns their school to a new SIT" do
    given_there_is_a_school_and_an_induction_coordinator
    and_i_am_signed_in_as_an_induction_coordinator

    click_on "Change induction tutor"
    then_i_should_be_on_the_change_sit_name_page
    and_the_page_should_be_accessible

    click_on "Continue"
    then_i_should_receive_a_full_name_error_message

    when_i_fill_in_the_sits_name
    click_on "Continue"
    then_i_should_be_on_the_change_sit_email_page
    and_the_page_should_be_accessible

    click_on "Continue"
    then_i_should_receive_a_blank_email_error_message

    when_i_input_an_invalid_email_format
    click_on "Continue"
    then_i_should_receive_an_invalid_email_error_message

    when_i_fill_in_the_sits_email
    click_on "Continue"
    then_i_should_be_on_the_check_details_page

    click_on "Accept and continue"
    then_i_should_be_on_confirm_sit_change_page
    and_the_page_should_be_accessible

    click_on "Confirm and replace"
    then_i_should_be_on_the_nominate_sit_success_page
    and_the_page_should_be_accessible

    visit "/schools"
    then_i_should_have_been_signed_out_of_the_service
  end

  scenario "a SIT with multiple schools assigns their school to a new SIT" do
    given_there_are_multiple_schools_with_the_same_induction_coordinator
    and_i_am_signed_in_as_an_induction_coordinator

    click_on "Test School 1"
    click_on "Change induction tutor"
    then_i_should_be_on_the_change_sit_name_page

    when_i_fill_in_the_sits_name
    click_on "Continue"
    then_i_should_be_on_the_nominations_email_page

    when_i_fill_in_the_sits_email
    click_on "Continue"
    then_i_should_be_on_the_check_details_page

    click_on "Accept and continue"
    then_i_should_be_on_confirm_sit_change_page

    click_on "Confirm and replace"
    then_i_should_be_on_the_nominate_sit_success_page

    visit "/schools"
    then_i_should_not_see_the_school_that_has_changed_sit
  end

private

  # given

  def given_there_is_a_school_and_an_induction_coordinator
    @cohort = Cohort.current || create(:cohort, :current)
    @school = create(:school, name: "Fip School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "full_induction_programme")

    create_partnership(@school)
    create_induction_tutor(@school)
  end

  def given_there_are_multiple_schools_with_the_same_induction_coordinator
    first_school = create(:school, name: "Test School 1", slug: "111111-test-school-1", urn: "111111")
    second_school = create(:school, name: "Test School 2", slug: "111112-test-school-2", urn: "111112")

    @cohort = Cohort.current || create(:cohort, :current)
    @school_cohort = create(:school_cohort, :cip, school: first_school, cohort: @cohort, induction_programme_choice: "full_induction_programme")

    create_partnership(first_school)
    create_induction_tutor(first_school, second_school)
  end

  # then

  def then_i_should_be_on_the_change_sit_name_page
    expect(page).to have_selector("label", text: "What’s the full name of the new induction tutor?")
  end

  def then_i_should_be_on_the_change_sit_email_page
    expect(page).to have_selector("label", text: "What’s #{@sit_data[:full_name]}’s email address?")
  end

  def then_i_should_be_on_the_nominate_sit_success_page
    expect(page).to have_selector("h1", text: "Your school’s induction tutor has been changed")
    expect(page).to have_selector("h2", text: "What happens next")
    expect(page).to have_text("We'll email #{@sit_data[:full_name]} and let them know that you nominated them.")
  end

  def then_i_should_be_on_confirm_sit_change_page
    expect(page).to have_selector("h1", text: "Are you sure you want to replace the induction tutor")
    expect(page).to have_text("You can only assign one induction tutor to use this service for your school.")
    expect(page).to have_text("You will no longer be able to")
  end

  def then_i_should_have_been_signed_out_of_the_service
    expect(page).to have_selector("h1", text: "Sign in")
    expect(current_path).to eq("/users/sign_in")
  end

  def then_i_should_not_see_the_school_that_has_changed_sit
    expect(page).not_to have_text("Test School 1")
    expect(page).to have_text("Test School 2")
  end

  # and

  def and_i_am_signed_in_as_an_induction_coordinator
    privacy_policy = create(:privacy_policy)
    privacy_policy.accept!(@induction_coordinator_profile.user)
    sign_in_as @induction_coordinator_profile.user
    set_induction_tutor_data
  end

  def create_induction_tutor(*schools)
    user = create(:user, full_name: "Induction Coordinator", email: "ic@example.com")
    @induction_coordinator_profile = create(:induction_coordinator_profile, schools:, user:)
  end

  def create_partnership(school)
    @lead_provider = create(:lead_provider, name: "Big Provider Ltd")
    @delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
    create(:partnership, school:, lead_provider: @lead_provider, delivery_partner: @delivery_partner, cohort: @cohort)
  end
end
