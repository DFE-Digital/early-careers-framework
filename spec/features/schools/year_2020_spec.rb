# frozen_string_literal: true

RSpec.describe "School leaders adding 2020 participants", :with_default_schedules, js: true do
  let(:school) { create(:school, name: "Test School") }

  let!(:core_induction_programme) { create(:core_induction_programme, name: "Awesome induction course") }

  scenario "Adding a 2020 participant" do
    when_i_visit start_schools_year_2020_path(school_id: school.slug)
    then_the_page_should_be_accessible

    click_on "Choose a provider"
    then_i_should_be_on choose_core_induction_programme_schools_year_2020_path(school_id: school.slug)
    and_the_page_should_be_accessible

    when_i_select "Awesome induction course"
    and_i_click_the_continue_button
    then_i_should_be_on add_teacher_schools_year_2020_path(school_id: school.slug)
    and_the_page_should_be_accessible

    when_i_add_first_teacher_details
    and_i_click_the_continue_button
    then_i_should_be_on check_your_answers_schools_year_2020_path(school_id: school.slug)
    and_the_page_should_be_accessible

    click_on "Add another teacher"
    then_i_should_be_on add_teacher_schools_year_2020_path(school_id: school.slug)

    when_i_add_second_teacher_details
    and_i_click_the_continue_button
    then_i_should_be_on check_your_answers_schools_year_2020_path(school_id: school.slug)
    and_the_page_should_be_accessible

    click_on "Change personal details", match: :first
    then_i_should_be_on edit_teacher_schools_year_2020_path(school_id: school.slug, index: 1)
    and_the_page_should_be_accessible

    fill_in "Full name", with: "James Bond 2"
    and_i_click_the_continue_button
    then_i_should_be_on check_your_answers_schools_year_2020_path(school_id: school.slug)
    and_the_page_should_be_accessible

    click_on "Delete", match: :first
    then_i_should_be_on remove_teacher_schools_year_2020_path(school_id: school.slug, index: 1)
    and_the_page_should_be_accessible

    click_button "Delete", class: "govuk-button", type: "submit"
    then_i_should_be_on check_your_answers_schools_year_2020_path(school_id: school.slug)
    and_the_page_should_be_accessible

    click_button "Confirm", class: "govuk-button", type: "submit"
    then_there_should_be_a_success_panel
    and_a_confirmation_email_should_be_sent
    and_the_page_should_be_accessible
  end

  def when_i_add_first_teacher_details
    fill_in "Full name", with: "James Bond"
    fill_in "Email", with: "james.bond.007@secret.gov.uk"
  end

  def when_i_add_second_teacher_details
    fill_in "Full name", with: "Dummy User"
    fill_in "Email", with: "dummy@secret.gov.uk"
  end

  def then_there_should_be_a_success_panel
    find(".govuk-panel__title").assert_text("now access their support materials")
  end

  def and_a_confirmation_email_should_be_sent
    expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
      .with(
        "SchoolMailer",
        "year2020_add_participants_confirmation",
        "deliver_now",
        a_hash_including(:args),
      )
  end
end
