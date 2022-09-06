# frozen_string_literal: true

require "rails_helper"
require_relative "./nominate_induction_tutor_steps"

RSpec.feature "ECT nominate SIT journey", type: :feature, js: true do
  include NominateInductionTutorSteps

  scenario "Valid nomination link was sent" do
    given_a_valid_nomination_email_has_been_created
    when_i_click_the_link_to_nominate_a_sit
    then_i_should_be_on_the_choose_how_to_continue_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Choose how to continue"

    when_i_select "yes"
    click_on "Continue"
    then_i_should_be_on_the_start_nomination_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Start SIT nomination"

    click_on "Continue"
    then_i_should_be_on_the_nominations_full_name_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Add SIT name"

    click_on "Continue"
    then_i_should_receive_a_full_name_error_message

    when_i_fill_in_the_sits_name
    click_on "Continue"
    then_i_should_be_on_the_nominations_email_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Add SIT email"

    click_on "Continue"
    then_i_should_receive_a_blank_email_error_message

    when_i_input_an_invalid_email_format
    click_on "Continue"
    then_i_should_receive_an_invalid_email_error_message

    when_i_fill_in_the_sits_email
    click_on "Continue"
    then_i_should_be_on_the_check_details_page

    click_on "Confirm and nominate"
    then_i_should_be_on_the_nominate_sit_success_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Nominate SIT completed"
  end

  scenario "Expired nomination link was sent" do
    given_a_valid_nomination_email_has_been_created
    and_the_nomination_email_link_has_expired
    when_i_click_the_link_to_nominate_a_sit
    then_i_should_be_redirected_to_the_link_expired_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Nominate a SIT link expired"
  end

  scenario "Nomination Link was sent for which Induction Tutor was already nominated for the same school" do
    given_an_induction_tutor_has_already_been_nominated
    when_i_click_the_link_to_nominate_a_sit
    then_i_should_be_redirected_to_the_induction_tutor_already_nominated_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "SIT already nominated"
  end

  scenario "Nominating an induction tutor with name and email that do not match" do
    given_an_email_address_for_another_school_sit_already_exists
    when_i_click_the_link_to_nominate_a_sit
    then_i_should_be_on_the_choose_how_to_continue_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "How to continue"

    when_i_select "yes"
    click_on "Continue"
    then_i_should_be_on_the_start_nomination_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Start school induction tutor nomination"

    click_on "Continue"
    then_i_should_be_on_the_nominations_full_name_page

    when_i_fill_in_the_sits_name
    click_on "Continue"
    then_i_should_be_on_the_nominations_email_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "SIT email does not match name"

    when_i_fill_in_using_an_email_that_is_already_being_used
    click_on "Continue"
    then_i_should_be_redirected_to_name_different_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Different name page"

    click_on "Change the name"
    then_i_should_be_on_the_nominations_full_name_page

    when_i_fill_in_the_sits_name
    click_on "Continue"
    then_i_should_be_on_the_nominations_email_page

    when_i_fill_in_the_sits_email
    click_on "Continue"
    then_i_should_be_on_the_check_details_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Check details"

    click_on "Confirm and nominate"
    then_i_should_be_on_the_nominate_sit_success_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Nominate SIT success"
  end

  scenario "Nominating an induction tutor with an email already in use by another school", :with_default_schedules do
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
    then_i_should_be_on_the_email_already_used_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "SIT nomination - Email already in use"

    when_i_click "Change email address"
    then_i_should_be_on_the_nominations_full_name_page

    when_i_fill_in_the_sits_name
    click_on "Continue"
    then_i_should_be_on_the_nominations_email_page

    when_i_fill_in_the_sits_email
    click_on "Continue"
    then_i_should_be_on_the_check_details_page

    click_on "Confirm and nominate"
    then_i_should_be_on_the_nominate_sit_success_page
  end
end
