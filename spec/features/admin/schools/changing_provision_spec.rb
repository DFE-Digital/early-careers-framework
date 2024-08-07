# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin managing school provision", js: true, rutabaga: false do
  scenario "Admin changes school provision" do
    given_there_is_a_cip_school_in_2021
    and_i_am_signed_in_as_an_admin
    when_i_visit the_school_cohorts_page
    and_i_click_the_change_training_programme_link
    then_i_should_be_on the_change_programme_page
    and_the_page_should_be_accessible

    when_i_select_fip
    and_i_click_the_continue_button
    then_i_should_be_on the_confirm_page
    and_the_page_should_be_accessible

    when_i_click_the_continue_button
    then_i_should_be_on the_school_cohorts_page
    and_there_should_be_a_success_banner
  end

private

  def given_there_is_a_cip_school_in_2021
    school = create(:school, name: "Test school")
    cohort = Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021)
    create(:seed_partnership, :with_lead_provider, :valid, cohort:, school:)
    @school_cohort = create(:seed_school_cohort, :cip, :valid, school:, cohort:)
  end

  def the_school_cohorts_page
    admin_school_cohorts_path(school_id: @school_cohort.school.slug)
  end

  def the_change_programme_page
    admin_school_change_programme_path(school_id: @school_cohort.school.slug, id: @school_cohort.cohort.start_year)
  end

  def when_i_select_fip
    choose option: "full_induction_programme", allow_label_click: true
  end

  def the_confirm_page
    confirm_admin_school_change_programme_path(school_id: @school_cohort.school.slug, id: @school_cohort.cohort.start_year)
  end

  def and_i_click_the_change_training_programme_link
    href = admin_school_change_programme_path(@school_cohort.school.slug, @school_cohort.cohort.start_year)

    page.find(%(a[href='#{href}'])).click
  end
end
