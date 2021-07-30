# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin managing school provision", js: true, rutabaga: false do
  scenario "Admin challenges school partnership" do
    given_there_is_a_partnered_school
    and_i_am_signed_in_as_an_admin
    when_i_visit the_school_cohorts_page
    and_i_click_the_link_containing "Change"

    then_i_should_be_on the_challenge_partnership_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Admin challenge partnership page")

    when_i_select_mistake
    and_i_click_the_submit_button
    then_i_should_be_on the_confirm_page
    and_the_page_should_contain_lead_provider_name
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Admin confirm challenge partnership page")

    when_i_click_the_submit_button
    then_i_should_be_on the_school_cohorts_page
    and_there_should_be_a_success_banner
  end

private

  def given_there_is_a_partnered_school
    @school = create(:school, name: "Test School")
    @cohort = create(:cohort, start_year: 2021)
    @partnership = create(:partnership, school: @school, cohort: @cohort)
    create(:school_cohort, cohort: @cohort, school: @school, induction_programme_choice: "full_induction_programme")
  end

  def the_school_cohorts_page
    admin_school_cohorts_path(school_id: @school.slug)
  end

  def the_challenge_partnership_page
    new_admin_school_challenge_partnership_path(school_id: @school.slug, id: @cohort.start_year)
  end

  def when_i_select_mistake
    choose option: "mistake", allow_label_click: true
  end

  def the_confirm_page
    confirm_admin_school_challenge_partnership_path(school_id: @school.slug, id: @cohort.start_year)
  end

  def and_the_page_should_contain_lead_provider_name
    expect(page).to have_content @partnership.lead_provider.name
  end
end
