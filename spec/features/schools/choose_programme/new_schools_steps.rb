# frozen_string_literal: true

module NewSchoolsSteps
  include Capybara::DSL

  def given_a_new_school
    @cohort = create(:cohort, start_year: 2022)
    @school = create(:school, name: "New School")
  end

  def then_i_am_on_the_how_you_run_your_training_page
    expect(page).to have_content("How do you want to run your training")
  end

  def when_i_choose_no_ects_expected
    choose("We do not expect any early career teachers to join")
  end

  def and_i_click_on_continue
    click_on("Continue")
  end

  def then_i_am_on_the_confirm_your_training_page
    expect(page).to have_content("Confirm your training programme")
  end

  def when_i_click_on_confirm
    click_on("Confirm")
  end

  def then_i_am_on_the_training_submitted_page
    expect(page).to have_content("You’ve submitted your training information")
  end

  def and_i_dont_see_appropriate_body_reported_title
    expect(page).to_not have_content("and reported your appropriate body")
  end

  def and_i_see_appropriate_body_reminder
    expect(page).to have_content("tell us which appropriate body you’ve appointed for your ECTs")
  end

  def and_i_dont_see_appropriate_body_reminder
    expect(page).to_not have_content("tell us which appropriate body you’ve appointed for your ECTs")
  end

  def when_i_go_to_manage_your_training_page
    click_on("Continue to manage your training")
  end

  def then_i_see_no_ects_expected_confirmation
    expect(page).to have_content("Your school has told us you do not expect any ECTs")
  end

  def when_i_choose_deliver_own_programme
    if FeatureFlag.active?(:programme_type_changes_2025)
      choose("School-led")
    else
      choose("Deliver your own programme using DfE-accredited materials")
    end
  end

  def then_i_see_appropriate_body_appointed_page
    expect(page).to have_content("Have you appointed an appropriate body?")
  end

  def when_i_choose_yes
    choose("Yes")
  end

  def when_i_choose_national_organisation
    choose("National organisation")
  end

  def then_i_see_appropriate_body_reported_confirmation
    expect(page).to have_content("You’ve submitted your training information and reported your appropriate body")
  end

  def then_i_am_on_the_manage_your_training_page
    expect(page).to have_content("Manage your training")
  end

  def when_i_choose_appropriate_body
    choose @appropriate_body.name
  end

  def and_i_see_appropriate_body_saved
    expect(page).to have_summary_row("Appropriate body", @appropriate_body.name)
  end

  def and_i_see_no_appropriate_body_selected
    expect(page).to have_summary_row("Appropriate body", "")
  end

  def when_i_choose_no
    choose("No")
  end
end
