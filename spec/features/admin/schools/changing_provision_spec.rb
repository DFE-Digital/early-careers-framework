# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin managing school provision", js: true, rutabaga: false do
  scenario "Admin changes school provision" do
    given_there_is_a_fip_school_in_2021
    and_i_am_signed_in_as_an_admin
    when_i_visit the_school_cohorts_page
    and_i_click_the_link_containing "Change"
    then_i_should_be_on the_change_programme_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Admin choose programme page")

    when_i_select_cip
    and_i_click_the_continue_button
    then_i_should_be_on the_confirm_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Admin confirm programme page")

    when_i_click_the_continue_button
    then_i_should_be_on the_school_cohorts_page
    and_there_should_be_a_success_banner
  end

private

  def given_there_is_a_fip_school_in_2021
    school = create(:school, name: "Test school")
    cohort = create(:cohort, start_year: 2021)
    @school_cohort = create(:school_cohort, school: school, cohort: cohort, induction_programme_choice: "full_induction_programme")
  end

  def the_school_cohorts_page
    admin_school_cohorts_path(school_id: @school_cohort.school.slug)
  end

  def the_change_programme_page
    admin_school_change_programme_path(school_id: @school_cohort.school.slug, id: @school_cohort.cohort.start_year)
  end

  def when_i_select_cip
    choose option: "core_induction_programme", allow_label_click: true
  end

  def the_confirm_page
    confirm_admin_school_change_programme_path(school_id: @school_cohort.school.slug, id: @school_cohort.cohort.start_year)
  end
end
