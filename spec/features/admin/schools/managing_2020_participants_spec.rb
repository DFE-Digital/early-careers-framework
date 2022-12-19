# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin managing 2020 participants", js: true, rutabaga: false do
  scenario "Admin views participants and adds a new one" do
    given_there_is_a_school_with_2020_cohort
    and_i_am_signed_in_as_an_admin
    when_i_visit the_school_2020_cohort_page
    then_the_page_should_be_accessible

    when_i_click_the_link_containing "Add new"
    then_i_should_be_on the_add_nqt_page
    and_the_page_should_be_accessible

    when_i_fill_the_form_in
    and_i_click_the_save_button
    then_i_should_be_on the_school_2020_cohort_page
    and_there_should_be_a_success_banner
    and_the_page_should_contain_the_new_user
  end

private

  def given_there_is_a_school_with_2020_cohort
    school = create(:school, name: "Test school")
    cohort = Cohort[2020] || create(:cohort, start_year: 2020)
    create(:ecf_schedule, cohort: Cohort[2021] || create(:cohort, start_year: 2021))
    core_induction_programme = create(:core_induction_programme)
    @school_cohort = create(:school_cohort, :cip, school:, cohort:, core_induction_programme:)
    create(:ect_participant_profile, school_cohort: @school_cohort, user: create(:user, full_name: "Test NQT+1"))
  end

  def the_school_2020_cohort_page
    admin_school_cohort2020_path(school_id: @school_cohort.school.slug)
  end

  def the_add_nqt_page
    new_admin_school_cohort2020_path(school_id: @school_cohort.school.slug)
  end

  def when_i_fill_the_form_in
    fill_in "Full name", with: "New NQT+1"
    fill_in "Email", with: "new@email.com"
  end

  def and_the_page_should_contain_the_new_user
    expect("New NQT+1").to be_present
  end
end
