# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin managing school provision", js: true, rutabaga: false do
  scenario "Admin changes training materials" do
    given_there_is_a_cip_school_in_2021
    and_there_is_another_core_induction_programme
    and_i_am_signed_in_as_an_admin
    and_feature_flag_is_active :admin_change_materials
    when_i_visit the_school_cohorts_page
    and_i_click_the_change_materials_link
    then_i_should_be_on the_change_materials_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Admin change materials page")

    when_i_select_ambition
    and_i_click_the_submit_button
    then_i_should_be_on the_confirm_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Admin confirm change materials page")

    when_i_click_the_submit_button
    then_i_should_be_on the_school_cohorts_page
    and_there_should_be_a_success_banner
  end

private

  def given_there_is_a_cip_school_in_2021
    school = create(:school, name: "Test school")
    cohort = create(:cohort, start_year: 2021)
    chosen_cip = create(:core_induction_programme, name: "Chosen CIP")
    @school_cohort = create(:school_cohort,
                            school: school,
                            cohort: cohort,
                            induction_programme_choice: "core_induction_programme",
                            core_induction_programme: chosen_cip)
  end

  def and_there_is_another_core_induction_programme
    @other_cip = create(:core_induction_programme, name: "Other CIP")
  end

  def the_school_cohorts_page
    admin_school_cohorts_path(school_id: @school_cohort.school.slug)
  end

  def and_i_click_the_change_materials_link
    find("[data-test=change-materials]").click
  end

  def the_change_materials_page
    admin_school_change_training_materials_path(school_id: @school_cohort.school.slug, id: @school_cohort.cohort.start_year)
  end

  def when_i_select_ambition
    choose option: @other_cip.id, allow_label_click: true
  end

  def the_confirm_page
    confirm_admin_school_change_training_materials_path(school_id: @school_cohort.school.slug, id: @school_cohort.cohort.start_year)
  end
end
