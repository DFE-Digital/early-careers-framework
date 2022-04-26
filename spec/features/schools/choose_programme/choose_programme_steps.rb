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
    @previous_cohort = create(:cohort, start_year: 2020)
    @cohort = create(:cohort, start_year: 2021)
    @school = create(:school, name: "NoECTsSchool")
    create(:school_cohort, :cip, school: @school, cohort: @previous_cohort)
  end

  # Then steps

  def then_I_am_taken_to_ects_expected_in_next_academic_year_page
    expect(page).to have_content(@school.name)
    expect(page).to have_content("Does your school expect any ECTs in the next academic year?")
  end

  def then_I_am_taken_to_the_confirmation_page
    expect(page).to have_content("Your information has been saved")
  end

  def then_I_am_taken_to_the_manage_your_training_page
    expect(page).to have_content("Manage your training")
  end

  # And steps

  def and_i_am_signed_in_as_an_induction_coordinator
    @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school], user: create(:user, full_name: "Carl Coordinator"))
    privacy_policy = create(:privacy_policy)
    privacy_policy.accept!(@induction_coordinator_profile.user)
    sign_in_as @induction_coordinator_profile.user
  end

  def and_I_click_continue
    click_on("Continue")
  end

  # When steps

  def when_I_start_programme_selection_for_next_cohort
    visit does_your_school_expect_any_ects_schools_setup_school_cohort_path(@school, @cohort)
  end

  def when_I_choose_no_ects
    choose("No")
  end

  def when_I_click_on_the_return_to_your_training_link
    click_on("Return to manage your training")
  end

end
