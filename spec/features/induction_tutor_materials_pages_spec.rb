# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Induction Tutor Materials", type: :feature, js: true, rutabaga: false do
  # All users should be able to view Induction Tutor materials for each cip provider.

  scenario "Ambition Year One Induction Tutor materials are accessible" do
    given_i_am_on_the_ambition_year_one_induction_tutor_materials_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "ambition year one induction materials"
  end

  scenario "Ambition Year Two Induction Tutor materials are accessible" do
    given_i_am_on_the_ambition_year_two_induction_tutor_materials_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "ambition year two induction materials"
  end

  scenario "EDT Year One Induction Tutor materials are accessible" do
    given_i_am_on_the_edt_year_one_induction_tutor_materials_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "edt year one induction materials"
  end

  scenario "EDT Year Two Induction Tutor materials are accessible" do
    given_i_am_on_the_edt_year_two_induction_tutor_materials_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "edt year two induction materials"
  end

  scenario "Teach First Year One and Two Induction Tutor materials are accessible" do
    given_i_am_on_the_teach_first_year_one_induction_tutor_materials_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "teach first year one and two induction materials"
  end

  scenario "UCL Year One Induction Tutor materials are accessible" do
    given_i_am_on_the_ucl_year_one_induction_tutor_materials_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "ucl year one induction materials"
  end

  scenario "UCL Year Two Induction Tutor materials are accessible" do
    given_i_am_on_the_ucl_year_two_induction_tutor_materials_page
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "ucl year two induction materials"
  end
end
