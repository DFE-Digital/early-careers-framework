# frozen_string_literal: true

RSpec.feature "Admin should be able to update participants details", js: true, rutabaga: false do
  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_admin
    and_i_have_added_an_ect
    and_i_have_added_a_mentor
    when_i_visit_admin_participants_dashboard
    then_i_should_see_a_list_of_participants
  end

  scenario "Admin can edit a participants name" do
    when_i_click_on_the_participants_name "Sally Teacher"
    then_i_should_see_the_ects_details

    when_i_click_on_change_name
    then_i_should_be_on_the_edit_name_page

    when_i_update_the_name_with ""
    and_i_click_on_continue
    then_i_should_receive_a_missing_name_error_message

    when_i_update_the_name_with "Sandra Teacher"
    and_i_click_on_continue
    then_i_should_be_in_the_admin_participants_dashboard
    and_admin_should_be_shown_a_success_message
    and_the_page_should_have_the_updated_name "Sandra Teacher"
  end

  scenario "Admin can edit a participants email" do
    when_i_click_on_the_participants_name "Billy Mentor"
    then_i_should_see_the_mentors_details

    when_i_click_on_change_email
    then_i_should_be_on_the_edit_email_page

    when_i_update_the_email_with "invalid@email"
    and_i_click_on_continue
    then_i_should_receive_a_invalid_email_error_message

    when_i_update_the_email_with ""
    and_i_click_on_continue
    then_i_should_receive_a_missing_email_error_message

    when_i_update_the_email_with @participant_profile_ect.user.email
    and_i_click_on_continue
    then_i_should_receive_an_email_already_taken_error_message

    when_i_update_the_email_with "billy@mentor-example.com"
    and_i_click_on_continue
    then_i_should_be_in_the_admin_participants_dashboard
    and_admin_should_be_shown_a_success_message

    when_i_click_on_the_participants_name "Billy Mentor"
    then_the_participants_email_should_have_updated "billy@mentor-example.com"
  end

private

  # Given

  def given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    @cohort = create(:cohort, start_year: 2021)
    @school = create(:school, name: "Fip School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "full_induction_programme")
  end

  # When

  def when_i_visit_admin_participants_dashboard
    visit admin_participants_path
  end

  def when_i_click_on_the_participants_name(name)
    click_on name
  end

  def when_i_click_on_change_name
    click_on("Change name", visible: false)
  end

  def when_i_click_on_change_email
    click_on("Change email", visible: false)
  end

  def when_i_update_the_name_with(name)
    fill_in "Full name", with: name
  end

  def when_i_update_the_email_with(email)
    fill_in "Email address", with: email
  end

  # Then

  def then_i_should_be_on_the_edit_name_page
    expect(page).to have_text("Change ECT’s name")
  end

  def then_i_should_be_on_the_edit_email_page
    expect(page).to have_text("Change mentor’s email address")
  end

  def then_i_should_see_the_ects_details
    expect(page).to have_text(@participant_profile_ect.user.full_name)
    have_link "Change", href: edit_name_admin_participant_path(id: @participant_profile_ect.id)
    have_link "Change", href: edit_email_admin_participant_path(id: @participant_profile_ect.id)
  end

  def then_i_should_see_the_mentors_details
    expect(page).to have_text(@participant_profile_mentor.user.full_name)
    have_link "Change", href: edit_name_admin_participant_path(id: @participant_profile_mentor.id)
    have_link "Change", href: edit_email_admin_participant_path(id: @participant_profile_mentor.id)
  end

  def then_i_should_see_a_list_of_participants
    expect(page).to have_text("Fip School")
    expect(page).to have_text("Sally Teacher")
  end

  def then_i_should_be_in_the_admin_participants_dashboard
    expect(page).to have_selector("h1", text: "Participants")
  end

  def then_the_participants_email_should_have_updated(email)
    expect(page).to have_text(email)
  end

  def then_i_should_receive_a_missing_name_error_message
    expect(page).to have_text("Enter a full name")
  end

  def then_i_should_receive_a_missing_email_error_message
    expect(page).to have_text("Enter an email")
  end

  def then_i_should_receive_an_email_already_taken_error_message
    expect(page).to have_text("This email address is already in use")
  end

  def then_i_should_receive_a_invalid_email_error_message
    expect(page).to have_text("Enter an email address in the correct format, like name@example.com")
  end

  # And

  def and_i_have_added_an_ect
    @participant_profile_ect = create(:ect_participant_profile, user: create(:user, full_name: "Sally Teacher"), school_cohort: @school_cohort)
  end

  def and_i_have_added_a_mentor
    @participant_profile_mentor = create(:mentor_participant_profile, user: create(:user, full_name: "Billy Mentor"), school_cohort: @school_cohort)
  end

  def and_i_click_on_continue
    click_on("Continue")
  end

  def and_admin_should_be_shown_a_success_message
    expect(page).to have_selector ".govuk-notification-banner--success"
  end

  def and_the_page_should_have_the_updated_name(name)
    expect(page).to have_text(name)
  end
end
