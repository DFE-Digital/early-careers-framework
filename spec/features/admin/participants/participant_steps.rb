# frozen_string_literal: true

module ParticipantSteps
  include Capybara::DSL

  # Given

  def given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    @cohort = Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021)
    @school = create(:school, name: "Fip School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "full_induction_programme")
    @induction_programme = create(:induction_programme, :fip, school_cohort: @school_cohort)
  end

  def setup_participant
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_i_am_signed_in_as_an_admin
    and_i_have_added_an_ect
    and_i_have_added_a_mentor
    when_i_visit_admin_participants_dashboard
    then_i_should_see_a_list_of_participants
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

  def when_i_click_on_add_notes
    click_on("Add notes")
  end

  def when_i_update_the_name_with(name)
    fill_in "Full name", with: name
  end

  def when_i_update_the_email_with(email)
    fill_in "Email address", with: email
  end

  def when_i_add_notes_to_the_participants_record
    fill_in "notes", with: "The participants notes have been updated"
  end

  def when_i_click_on_tab(text)
    within(".app-subnav") { click_on(text) }
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
    have_link "Change", href: edit_name_admin_participant_path(@participant_profile_ect.id)
    have_link "Change", href: edit_email_admin_participant_path(@participant_profile_ect.id)
  end

  def then_i_should_see_the_mentors_details
    expect(page).to have_text(@participant_profile_mentor.user.full_name)
    have_link "Change", href: edit_name_admin_participant_path(@participant_profile_mentor.id)
    have_link "Change", href: edit_email_admin_participant_path(@participant_profile_mentor.id)
  end

  def then_i_should_see_a_list_of_participants
    expect(page).to have_text("Fip School")
    expect(page).to have_text("Sally Teacher")
  end

  def then_i_should_be_in_the_admin_participants_dashboard
    expect(page).to have_selector("h1", text: "Participants")
  end

  def then_i_should_be_on_the_edit_notes_page
    expect(page).to have_selector("h1", text: "Add notes")
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

  def then_i_should_be_on_the_participant_school_page
    expect(current_path).to eql(admin_participant_school_path(@participant_profile_ect))
  end

  def then_i_should_be_on_the_participant_history_page
    expect(current_path).to eql(admin_participant_history_path(@participant_profile_ect))
  end

  def then_i_should_be_on_the_participant_induction_records_page
    expect(current_path).to eql(admin_participant_induction_records_path(@participant_profile_ect))
  end

  def then_i_should_be_on_the_participant_cohorts_page
    expect(current_path).to eql(admin_participant_cohorts_path(@participant_profile_ect))
  end

  def then_i_should_be_on_the_participant_declaration_history_page
    expect(current_path).to eql(admin_participant_declaration_history_path(@participant_profile_ect))
  end

  def then_i_should_be_on_the_participant_validation_data_page
    expect(current_path).to eql(admin_participant_validation_data_path(@participant_profile_ect))
  end

  def then_i_should_be_on_the_participant_identities_page
    expect(current_path).to eql(admin_participant_identities_path(@participant_profile_ect))
  end

  # And

  def and_i_have_added_an_ect
    @participant_profile_ect = create(:ect_participant_profile, user: create(:user, full_name: "Sally Teacher", email: "sally-teacher@example.com"), school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @participant_profile_ect, induction_programme: @induction_programme)
  end

  def and_i_have_added_a_mentor
    @participant_profile_mentor = create(:mentor_participant_profile, user: create(:user, full_name: "Billy Mentor", email: "billy-mentor@example.com"), school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @participant_profile_mentor, induction_programme: @induction_programme)
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

  def and_the_page_should_have_no_notes
    expect(page).to have_text("No notes")
    expect(page).to have_text("Add notes")
  end

  def and_the_notes_that_have_been_added
    expect(page).to have_text("The participants notes have been updated")
  end

  def and_i_should_see_the_current_schools_details
    expect(page).to have_text(@school.urn)
    expect(page).to have_text(@school.name)
  end

  def and_i_should_see_the_participant_history
    expect(page).to have_css("h2", text: "Key events")
  end

  def and_i_should_see_the_participant_induction_records
    expect(page).to have_css("h2", text: "Induction records")
  end

  def and_i_should_see_the_participant_cohorts
    expect(page).to have_text("Cohort")
    expect(page).to have_link("Change cohort")
  end

  def and_i_should_see_the_participant_declaration_history
    expect(page).to have_text("has no declarations")
  end

  def and_i_should_see_the_participant_validation_data
    expect(page).to have_text("Full name")
    expect(page).to have_text("Date of birth")
    expect(page).to have_text("Teacher Reference Number")
    expect(page).to have_text("National Insurance Number")
  end

  def and_i_should_see_the_participant_identities
    expect(page).to have_css("h2", text: "Identities")
    expect(page).to have_text(@participant_profile_ect.user.email)
  end
end
