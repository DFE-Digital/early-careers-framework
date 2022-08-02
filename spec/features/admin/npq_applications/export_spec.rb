# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin NPQ Application export system", js: true, rutabaga: false do
  scenario "Admin enqueues an export" do
    given_there_is_an_npq_application
    and_i_am_signed_in_as_an_admin

    when_i_visit the_npq_applications_export_page

    when_i_fill_in :admin_application_exports_form_start_date_3i, with: "6"
    when_i_fill_in :admin_application_exports_form_start_date_2i, with: "6"
    when_i_fill_in :admin_application_exports_form_start_date_1i, with: "2022"

    when_i_fill_in :admin_application_exports_form_end_date_3i, with: "1"
    when_i_fill_in :admin_application_exports_form_end_date_2i, with: "7"
    when_i_fill_in :admin_application_exports_form_end_date_1i, with: "2022"

    expect {
      when_i_click_the_button_labelled("Schedule Export")
    }.to have_enqueued_job(
      Admin::NPQApplications::ExportJob,
    ).with { |npq_application_export|
      expect(npq_application_export.user).to eq @logged_in_admin_user
      expect(npq_application_export.start_date).to eq Date.new(2022, 6, 6)
      expect(npq_application_export.end_date).to eq Date.new(2022, 7, 1)
    }

    expect(
      NPQApplications::Export.find_by(
        user: @logged_in_admin_user,
        start_date: Date.new(2022, 6, 6),
        end_date: Date.new(2022, 7, 1),
      ),
    ).to be_present

    then_i_should_be_on the_npq_applications_export_page
    and_the_page_should_be_accessible
    and_there_should_be_a_success_banner
  end

  scenario "Admin enters invalid dates" do
    given_there_is_an_npq_application
    and_i_am_signed_in_as_an_admin

    when_i_visit the_npq_applications_export_page

    when_i_fill_in :admin_application_exports_form_start_date_3i, with: "6"
    when_i_fill_in :admin_application_exports_form_start_date_2i, with: "31"
    when_i_fill_in :admin_application_exports_form_start_date_1i, with: "2022"

    when_i_fill_in :admin_application_exports_form_end_date_3i, with: "7"
    when_i_fill_in :admin_application_exports_form_end_date_2i, with: "31"
    when_i_fill_in :admin_application_exports_form_end_date_1i, with: "2022"

    expect {
      when_i_click_the_button_labelled("Schedule Export")
    }.to_not have_enqueued_job(Admin::NPQApplications::ExportJob)

    expect(NPQApplications::Export.any?).to be_falsey

    then_i_should_be_on the_npq_applications_exports_page
    and_the_page_should_be_accessible

    then_i_see_an_error_message("Please enter a valid start date")
    then_i_see_an_error_message("Please enter a valid end date")
  end

  scenario "Admin enters no dates" do
    given_there_is_an_npq_application
    and_i_am_signed_in_as_an_admin

    when_i_visit the_npq_applications_export_page

    expect {
      when_i_click_the_button_labelled("Schedule Export")
    }.to_not have_enqueued_job(Admin::NPQApplications::ExportJob)

    expect(NPQApplications::Export.any?).to be_falsey

    then_i_should_be_on the_npq_applications_exports_page
    and_the_page_should_be_accessible

    then_i_see_an_error_message("Please enter a start date")
    then_i_see_an_error_message("Please enter an end date")
  end

  scenario "Admin enters an end date before start date" do
    given_there_is_an_npq_application
    and_i_am_signed_in_as_an_admin

    when_i_visit the_npq_applications_export_page

    when_i_fill_in :admin_application_exports_form_start_date_3i, with: "31"
    when_i_fill_in :admin_application_exports_form_start_date_2i, with: "6"
    when_i_fill_in :admin_application_exports_form_start_date_1i, with: "2022"

    when_i_fill_in :admin_application_exports_form_end_date_3i, with: "29"
    when_i_fill_in :admin_application_exports_form_end_date_2i, with: "6"
    when_i_fill_in :admin_application_exports_form_end_date_1i, with: "2022"

    expect {
      when_i_click_the_button_labelled("Schedule Export")
    }.to_not have_enqueued_job(Admin::NPQApplications::ExportJob)

    expect(NPQApplications::Export.any?).to be_falsey

    then_i_should_be_on the_npq_applications_exports_page
    and_the_page_should_be_accessible

    then_i_see_an_error_message("End date must be after start date")
  end

  scenario "Admin enters an start date before relaunch date" do
    given_there_is_an_npq_application
    and_i_am_signed_in_as_an_admin

    when_i_visit the_npq_applications_export_page

    when_i_fill_in :admin_application_exports_form_start_date_3i, with: "1"
    when_i_fill_in :admin_application_exports_form_start_date_2i, with: "6"
    when_i_fill_in :admin_application_exports_form_start_date_1i, with: "2022"

    when_i_fill_in :admin_application_exports_form_end_date_3i, with: "29"
    when_i_fill_in :admin_application_exports_form_end_date_2i, with: "6"
    when_i_fill_in :admin_application_exports_form_end_date_1i, with: "2022"

    expect {
      when_i_click_the_button_labelled("Schedule Export")
    }.to_not have_enqueued_job(Admin::NPQApplications::ExportJob)

    expect(NPQApplications::Export.any?).to be_falsey

    then_i_should_be_on the_npq_applications_exports_page
    and_the_page_should_be_accessible

    then_i_see_an_error_message("Start date must be after 6th June 2022")
  end

private

  def given_there_is_an_npq_application
    create(:npq_application)
  end

  def the_npq_applications_export_page
    new_admin_npq_applications_export_path
  end

  def the_npq_applications_exports_page
    admin_npq_applications_exports_path
  end
end
