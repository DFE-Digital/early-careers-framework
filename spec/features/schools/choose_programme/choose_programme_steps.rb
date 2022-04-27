# frozen_string_literal: true

module ChooseProgrammeSteps
  include Capybara::DSL

  def freeze_time
    Timecop.freeze(Time.zone.local(2021, 5, 15, 16, 15, 0))
  end

  def reset_time
    Timecop.return
  end

  # Given steps

  def given_a_school_with_no_chosen_programme_for_next_academic_year
    @previous_cohort = create(:cohort, start_year: 2021)
    @cohort = create(:cohort, start_year: 2022)
    @school = create(:school, name: "NoECTsSchool")
    create(:school_cohort, :cip, school: @school, cohort: @previous_cohort)
  end

  # Then steps

  def then_i_am_taken_to_ects_expected_in_next_academic_year_page
    expect(page).to have_content(@school.name)
    expect(page).to have_content("Does your school expect any ECTs in the next academic year?")
  end

  def then_i_am_taken_to_the_submitted_page
    expect(page).to have_content("Your information has been saved")
  end

  def then_i_am_taken_to_the_manage_your_training_page
    expect(page).to have_content("Manage your training")
  end

  def then_i_am_taken_to_the_how_will_you_run_training_page
    expect(page).to have_content("How will you run training for new starters")
  end

  def then_i_am_taken_to_the_training_confirmation_page
    expect(page).to have_content("Are you sure this is how you want to run training?")
  end

  def then_i_am_taken_to_the_training_submitted_page
    expect(page).to have_content("You've submitted your training information")
  end

  # And steps

  def and_i_am_signed_in_as_an_induction_coordinator
    @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school], user: create(:user, full_name: "Carl Coordinator"))
    privacy_policy = create(:privacy_policy)
    privacy_policy.accept!(@induction_coordinator_profile.user)
    sign_in_as @induction_coordinator_profile.user
  end

  def and_i_click_continue
    click_on("Continue")
  end

  def and_cohort_2022_is_created
    create(:cohort, start_year: 2022)
  end

  def and_the_next_cohort_is_open_for_registrations
    Timecop.freeze(Time.zone.local(2022, 5, 10, 16, 15, 0))
  end

  def and_the_dashboard_page_shows_the_no_ects_message
    expect(page).to have_content("Your school has told us you do not expect any ECTs")
  end

  # When steps

  def when_i_start_programme_selection_for_next_cohort
    click_on("Start now")
  end

  def when_i_choose_no_ects
    choose("No")
  end

  def when_i_click_on_the_return_to_your_training_link
    click_on("Return to manage your training")
  end

  def when_i_choose_ects_expected
    choose("Yes")
  end

  def when_i_choose_dfe_funded_training
    choose("Use a training provider, funded by the DfE")
  end

  def when_i_click_the_confirm_button
    click_on("Confirm")
  end

  def when_i_choose_deliver_your_own_programme
    choose("Deliver your own programme using DfE-accredited materials")
  end

  def when_i_choose_design_and_deliver_your_own_material
    choose("Design and deliver you own programme based on the early career framework (ECF)")
  end
end
