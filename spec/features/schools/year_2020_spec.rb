# frozen_string_literal: true

RSpec.describe "School leaders adding 2020 participants", js: true, with_feature_flags: { year_2020_data_entry: "active" } do
  let(:school) { create(:school, name: "Test School") }
  let!(:cohort_2020) { create(:cohort, start_year: 2020) }
  let!(:core_induction_programme) { create(:core_induction_programme, name: "Awesome induction course") }
  let!(:schedule) { create(:schedule) }

  scenario "Adding a 2020 participant" do
    when_i_visit start_schools_year_2020_path(school_id: school.slug)
    then_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Year 2020 start page")

    click_on "Choose a provider"
    then_i_should_be_on choose_core_induction_programme_schools_year_2020_path(school_id: school.slug)
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Year 2020 CIP Choice page")

    when_i_select "Awesome induction course"
    and_i_click_the_submit_button
    then_i_should_be_on add_teacher_schools_year_2020_path(school_id: school.slug)
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Year 2020 add teacher page")

    when_i_add_first_teacher_details
    and_i_click_the_submit_button
    then_i_should_be_on check_your_answers_schools_year_2020_path(school_id: school.slug)
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Year 2020 check your answers page")

    click_on "Add another teacher"
    then_i_should_be_on add_teacher_schools_year_2020_path(school_id: school.slug)

    when_i_add_second_teacher_details
    and_i_click_the_submit_button
    then_i_should_be_on check_your_answers_schools_year_2020_path(school_id: school.slug)
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Year 2020 check your answers page with two teachers")

    click_on "Change personal details", { match: :first }
    then_i_should_be_on edit_teacher_schools_year_2020_path(school_id: school.slug, index: 1)
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Year 2020 edit teacher")

    fill_in "Full name", with: "James Bond 2"
    and_i_click_the_submit_button
    then_i_should_be_on check_your_answers_schools_year_2020_path(school_id: school.slug)
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Year 2020 check your answers page with two teachers edited")

    click_on "Delete", { match: :first }
    then_i_should_be_on remove_teacher_schools_year_2020_path(school_id: school.slug, index: 1)
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Year 2020 remove teacher")

    when_i_click_the_submit_button
    then_i_should_be_on check_your_answers_schools_year_2020_path(school_id: school.slug)
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Year 2020 check your answers page with a deleted teacher")

    when_i_click_the_submit_button
    then_there_should_be_a_success_panel
    and_a_confirmation_email_should_be_sent
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Year 2020 ect participant added")
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
    expect(SchoolMailer).to delay_email_delivery_of(:year2020_add_participants_confirmation)
  end
end
