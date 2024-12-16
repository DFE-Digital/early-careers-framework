# frozen_string_literal: true

module ParticipantSteps
  include Capybara::DSL

  def active_tab_selector
    ".app-subnav__list-item--selected"
  end

  # Given

  def given_the_ect_has_withdrawn_induction_status
    Induction::ChangeInductionRecord.call(induction_record: @induction_record, changes: { induction_status: :withdrawn })
  end

  def given_the_ect_has_leaving_induction_status
    Induction::ChangeInductionRecord.call(induction_record: @induction_record, changes: { induction_status: :leaving })
  end

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

  def when_i_visit_the_training_page_for_participant(participant_profile)
    visit admin_participant_school_path(participant_profile)
  end

  def when_i_visit_the_satuses_page_for_participant(participant_profile)
    visit admin_participant_statuses_path(participant_profile)
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

  def when_the_ect_has_withdrawn_induction_status
    @participant_profile_ect.latest_induction_record.update(induction_status:)
  end

  # Then

  def then_i_should_be_on_the_edit_name_page
    expect(page).to have_text("Change ECT’s name")
  end

  def then_i_should_be_on_the_edit_email_page
    expect(page).to have_text("Change mentor’s email address")
  end

  def then_i_should_be_on_the_edit_induction_status_page
    expect(page).to have_text("New induction status for #{@participant_profile_ect.full_name}")
  end

  def then_i_should_see_the_ects_details
    expect(page).to have_text(@participant_profile_ect.user.full_name)
    have_link "Change", href: admin_participant_change_name_path(@participant_profile_ect.id)
    have_link "Change", href: admin_participant_change_email_path(@participant_profile_ect.id)
  end

  def then_i_should_see_the_mentors_details
    expect(page).to have_text(@participant_profile_mentor.user.full_name)
    have_link "Change", href: admin_participant_change_name_path(@participant_profile_mentor.id)
    have_link "Change", href: admin_participant_change_email_path(@participant_profile_mentor.id)
  end

  def then_i_should_see_a_list_of_participants
    expect(page).to have_text("Fip School")
    expect(page).to have_text("Sally Teacher")
    expect(page).to have_text("Billy Mentor")
    expect(page).to have_text("Early career teacher")
    expect(page).to have_text("Mentor")
  end

  def then_i_should_be_in_the_admin_participants_dashboard
    expect(page).to have_selector("h1", text: "Participants")
  end

  def then_i_should_be_in_the_admin_participants_statuses_dashboard
    expect(page).to have_css(active_tab_selector, text: "Statuses")
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

  def then_i_should_be_on_the_participant_training_page
    expect(current_path).to eql(admin_participant_school_path(@participant_profile_ect))
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

  def and_a_new_induction_record_should_be_created
    expect(@participant_profile_ect.induction_records.count).to eq(3)
  end

  def and_i_have_added_an_ect
    @participant_profile_ect = create(:ect_participant_profile, user: create(:user, full_name: "Sally Teacher", email: "sally-teacher@example.com"), school_cohort: @school_cohort)
    @induction_record = Induction::Enrol.call(participant_profile: @participant_profile_ect, induction_programme: @induction_programme)
  end

  def and_i_click_on_change_induction_status
    click_on("Change induction status", visible: false)
  end

  def and_the_induction_record_should_have_school_transfer_true
    expect(@participant_profile_ect.latest_induction_record.school_transfer).to be true
  end

  def and_i_have_added_a_mentor
    @participant_profile_mentor = create(:mentor_participant_profile, user: create(:user, full_name: "Billy Mentor", email: "billy-mentor@example.com"), school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @participant_profile_mentor, induction_programme: @induction_programme)
    Mentors::AddToSchool.call(school: @school, mentor_profile: @participant_profile_mentor)
  end

  def and_the_mentor_is_mentoring_the_ect
    Induction::Enrol.call(
      participant_profile: @participant_profile_ect,
      mentor_profile: @participant_profile_mentor,
      induction_programme: @induction_programme,
    )
  end
  alias_method :given_the_mentor_is_mentoring_the_ect, :and_the_mentor_is_mentoring_the_ect

  def and_i_click_on_confirm
    click_on("Confirm")
  end
  alias_method :when_i_click_on_confirm, :and_i_click_on_confirm

  def and_i_click_on_continue
    click_on("Continue")
  end

  def and_admin_should_be_shown_a_success_message
    expect(page).to have_selector ".govuk-notification-banner--success"
  end

  def and_i_should_see_the_induction_statuses_are_active
    within(page.find("dt", text: /^induction status$/).ancestor(".govuk-summary-list__row").find("dd")) do
      expect(page).to have_text("Active")
    end
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
    expect(page).to have_text(@school.name)
  end

  def and_i_should_see_the_participant_training
    expect(page).to have_css(active_tab_selector, text: "Training")
  end

  def and_i_should_see_the_participant_induction_records
    expect(page).to have_css(active_tab_selector, text: "Training")
  end

  def and_i_should_see_the_participant_cohorts
    expect(page).to have_text("Cohort")
  end

  def and_i_should_see_the_change_cohort_action
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
    expect(page).to have_css(active_tab_selector, text: "Identities")
    expect(page).to have_text(@participant_profile_ect.user.email)
  end

  def and_the_page_title_should_be(expected_title)
    expect(page.title).to start_with(expected_title)
  end

  def when_i_click_change_preferred_identity_link
    within(page.find("dt", text: /^Preferred email$/).ancestor(".govuk-summary-list__row").find_all("dd")[1]) do
      click_on("Change")
    end
  end

  def then_i_should_see_all_the_user_participant_identities
    expect(page).to have_select("Select email", options: @participant_profile_ect.user.participant_identities.map(&:email))
  end

  def then_i_should_not_see_the_change_induction_status_link
    within(page.find("dt", text: /^induction status$/).ancestor(".govuk-summary-list__row").find("dd")) do
      expect(page).to_not have_link("change")
    end
  end
end
