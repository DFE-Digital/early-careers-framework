# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin managing appropriate bodies", js: true, rutabaga: false do
  scenario "Admin changes appropriate body for a 2021 cohort to IStip" do
    given_there_is_a_cip_school_in(2021)
    i_should_be_able_to_navigate_to_the_edit_page(2021)
    and_there_should_be_a_radio_button_for @listed_ab.name
    and_there_should_be_a_radio_button_for @listed_ab_2023_disabled.name
    and_there_should_be_a_radio_button_for "A teaching school hub"
    and_there_should_not_be_a_radio_button_for @listed_independent_schools_ab.name

    and_i_should_be_able_to_update_the_appropriate_body(@listed_ab.name, 2021)
  end

  scenario "Admin changes appropriate body of an independent school to IStip" do
    given_there_is_an_independent_cip_school_in(2021)
    i_should_be_able_to_navigate_to_the_edit_page(2021)
    and_there_should_be_a_radio_button_for @listed_ab.name
    and_there_should_be_a_radio_button_for @listed_ab_2023_disabled.name
    and_there_should_be_a_radio_button_for "A teaching school hub"
    and_there_should_be_a_radio_button_for @listed_independent_schools_ab.name

    and_i_should_be_able_to_update_the_appropriate_body(@listed_ab.name, 2021)
  end

  scenario "Admin changes appropriate body for a 2021 cohort to NTA" do
    given_there_is_a_cip_school_in(2021)
    i_should_be_able_to_navigate_to_the_edit_page(2021)
    and_there_should_be_a_radio_button_for @listed_ab.name
    and_there_should_be_a_radio_button_for @listed_ab_2023_disabled.name
    and_there_should_be_a_radio_button_for "A teaching school hub"

    and_i_should_be_able_to_update_the_appropriate_body(@listed_ab_2023_disabled.name, 2021)
  end

  scenario "Admin changes appropriate body for a 2021 cohort to a teaching school hub" do
    given_there_is_a_cip_school_in(2021)
    i_should_be_able_to_navigate_to_the_edit_page(2021)
    and_there_should_be_a_radio_button_for @listed_ab.name
    and_there_should_be_a_radio_button_for @listed_ab_2023_disabled.name
    and_there_should_be_a_radio_button_for "A teaching school hub"

    and_i_should_be_able_to_select_a_teaching_school_hub(2021)
  end

  scenario "Admin changes appropriate body for a 2023 cohort" do
    given_there_is_a_cip_school_in(2023)
    i_should_be_able_to_navigate_to_the_edit_page(2023)
    and_there_should_be_a_radio_button_for @listed_ab.name
    and_there_should_be_a_radio_button_for "A teaching school hub"
    and_there_should_not_be_a_radio_button_for @listed_ab_2023_disabled.name

    and_i_should_be_able_to_update_the_appropriate_body(@listed_ab.name, 2023)
  end

  scenario "Admin changes appropriate body for a DIY cohort" do
    given_there_is_a_cip_school_in(2023, induction_programme_choice: "design_our_own")
    i_should_be_able_to_navigate_to_the_edit_page(2023)
    and_there_should_be_a_radio_button_for @listed_ab.name
    and_there_should_be_a_radio_button_for "A teaching school hub"
    and_there_should_not_be_a_radio_button_for @listed_ab_2023_disabled.name

    and_i_should_be_able_to_update_the_appropriate_body(@listed_ab.name, 2023)
  end

private

  def given_there_is_a_cip_school_in(year, induction_programme_choice: "core_induction_programme", independent_school: false)
    @school = if independent_school
                create(:school, :independent_school, name: "Test school")
              else
                create(:school, name: "Test school")
              end
    cohort = Cohort.find_by(start_year: year) || create(:cohort, start_year: year)
    create(:seed_partnership, :with_lead_provider, :valid, cohort:, school: @school)

    chosen_cip = if induction_programme_choice == "core_induction_programme"
                   create(:core_induction_programme, name: "Chosen CIP")
                 end

    @school_cohort = create(:school_cohort,
                            school: @school,
                            cohort:,
                            induction_programme_choice:,
                            core_induction_programme: chosen_cip)
  end

  def given_there_is_an_independent_cip_school_in(year)
    given_there_is_a_cip_school_in(year, induction_programme_choice: "core_induction_programme", independent_school: true)
  end

  def and_there_are_the_required_appropriate_bodies
    @listed_ab = create(:appropriate_body_national_organisation, :supports_all_schools, listed: true)
    @listed_ab_2023_disabled = create(:appropriate_body_national_organisation, :supports_all_schools, listed: true, disable_from_year: 2023)
    @listed_independent_schools_ab = create(:appropriate_body_national_organisation, :supports_independent_schools_only, listed: true, name: "independent schools only")
    create(:appropriate_body_teaching_school_hub, name: "Example teaching school hub")
  end

  def and_there_is_another_core_induction_programme
    @other_cip = create(:core_induction_programme, name: "Other CIP")
  end

  def the_school_cohorts_page
    admin_school_cohorts_path(school_id: @school_cohort.school.slug)
  end

  def and_i_click_the_change_materials_link
    click_link("Change materials")
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

  def i_should_be_able_to_navigate_to_the_edit_page(year)
    and_there_is_another_core_induction_programme
    and_there_are_the_required_appropriate_bodies
    and_i_am_signed_in_as_an_admin
    when_i_visit the_school_cohorts_page
    and_i_click_the_change_appropriate_body_link(year)
    then_i_should_be_on the_appropriate_body_page(year)
    and_the_page_should_be_accessible
  end

  def and_i_should_be_able_to_select_a_teaching_school_hub(year)
    when_i_select "A teaching school hub"
    puts page.text
    fill_in "admin-schools-cohorts-appropriate-bodies-update-form-teaching-school-hub-id-field", with: "Example teaching school hub"
    find("#admin-schools-cohorts-appropriate-bodies-update-form-teaching-school-hub-id-field__option--0").click
    and_i_click_the_continue_button
    then_i_should_be_on the_school_cohorts_page
    and_there_should_be_a_success_banner
    and_the_appropriate_body_should_be_set_to "Example teaching school hub", year
  end

  def and_i_should_be_able_to_update_the_appropriate_body(appropriate_body, year)
    when_i_select appropriate_body
    and_i_click_the_continue_button
    then_i_should_be_on the_school_cohorts_page
    and_there_should_be_a_success_banner
    and_the_appropriate_body_should_be_set_to appropriate_body, year
  end

  def and_i_click_the_change_appropriate_body_link(year)
    within "#cohort-#{year}" do
      click_link("Change appropriate body for their #{year} programme", visible: false)
    end
  end

  def the_appropriate_body_page(year)
    edit_admin_school_cohort_appropriate_body_path(cohort_id: year, school_id: @school.slug)
  end

  def and_there_should_be_a_radio_button_for(appropriate_body)
    expect(page).to have_field(appropriate_body, visible: false)
  end

  def and_there_should_not_be_a_radio_button_for(appropriate_body)
    expect(page).to_not have_field(appropriate_body, visible: false)
  end

  def and_the_appropriate_body_should_be_set_to(appropriate_body, year)
    within "#cohort-#{year}" do
      expect(page).to have_content(appropriate_body)
    end
  end
end
