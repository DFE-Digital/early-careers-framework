# frozen_string_literal: true

require "rails_helper"
require_relative "./nominate_induction_tutor_steps"

RSpec.feature "ECT nominate SIT journey", type: :feature, js: true, early_in_cohort: true do
  include NominateInductionTutorSteps

  let(:academic_year_text) { Cohort.current.description }

  scenario "Valid nomination link was sent" do
    given_a_valid_nomination_email_has_been_created
    when_i_click_the_link_to_nominate_a_sit
    then_i_should_be_on_the_choose_how_to_continue_page
    and_the_page_should_be_accessible

    when_i_select "yes"
    click_on "Continue"
    then_i_should_be_on_the_start_nomination_page
    and_the_page_should_be_accessible

    click_on "Continue"
    then_i_should_be_on_the_nominations_full_name_page
    and_the_page_should_be_accessible

    click_on "Continue"
    then_i_should_receive_a_full_name_error_message

    when_i_fill_in_the_sits_name
    click_on "Continue"
    then_i_should_be_on_the_nominations_email_page
    and_the_page_should_be_accessible

    click_on "Continue"
    then_i_should_receive_a_blank_email_error_message

    when_i_input_an_invalid_email_format
    click_on "Continue"
    then_i_should_receive_an_invalid_email_error_message

    when_i_fill_in_the_sits_email
    click_on "Continue"
    then_i_should_be_on_the_check_details_page

    click_on "Confirm details"
    then_i_should_be_on_the_nominate_sit_success_page
    and_the_page_should_be_accessible
  end

  scenario "Expired nomination link was sent" do
    given_a_valid_nomination_email_has_been_created
    and_the_nomination_email_link_has_expired
    when_i_click_the_link_to_nominate_a_sit
    then_i_should_be_redirected_to_the_link_expired_page
    and_the_page_should_be_accessible
  end

  scenario "Nomination Link was sent for which Induction Tutor was already nominated for the same school" do
    given_an_induction_tutor_has_already_been_nominated
    when_i_click_the_link_to_nominate_a_sit
    then_i_should_be_redirected_to_the_nominate_induction_tutor_page
    and_the_page_should_be_accessible
  end

  scenario "Nominating an induction tutor with name and email that do not match" do
    given_an_email_address_for_another_school_sit_already_exists
    when_i_click_the_link_to_nominate_a_sit
    then_i_should_be_on_the_choose_how_to_continue_page
    and_the_page_should_be_accessible

    when_i_select "yes"
    click_on "Continue"
    then_i_should_be_on_the_start_nomination_page
    and_the_page_should_be_accessible

    click_on "Continue"
    then_i_should_be_on_the_nominations_full_name_page

    when_i_fill_in_the_sits_name
    click_on "Continue"
    then_i_should_be_on_the_nominations_email_page
    and_the_page_should_be_accessible

    when_i_fill_in_using_an_email_that_is_already_being_used
    click_on "Continue"
    then_i_should_see_the_name_not_match_error
    and_the_page_should_be_accessible

    click_on "Back"
    then_i_should_be_on_the_nominations_full_name_page

    when_i_fill_in_the_sits_name
    click_on "Continue"
    then_i_should_be_on_the_nominations_email_page

    when_i_fill_in_the_sits_email
    click_on "Continue"
    then_i_should_be_on_the_check_details_page
    and_the_page_should_be_accessible

    click_on "Confirm details"
    then_i_should_be_on_the_nominate_sit_success_page
    and_the_page_should_be_accessible
  end

  scenario "Nominating an induction tutor with an email already in use by another school" do
    given_an_email_is_being_used_by_an_existing_ect
    when_i_click_the_link_to_nominate_a_sit
    then_i_should_be_on_the_choose_how_to_continue_page

    when_i_select "yes"
    click_on "Continue"
    then_i_should_be_on_the_start_nomination_page

    click_on "Continue"
    then_i_should_be_on_the_nominations_full_name_page
    when_i_fill_in_the_sits_name
    click_on "Continue"
    then_i_should_be_on_the_nominations_email_page

    when_i_fill_in_using_an_ects_email
    click_on "Continue"
    then_i_should_be_on_the_check_details_page

    click_on "Confirm details"
    then_i_should_be_on_the_nominate_sit_success_page
  end
end
