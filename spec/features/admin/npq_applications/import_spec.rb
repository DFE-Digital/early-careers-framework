# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin NPQ Application import system", js: true, rutabaga: false do
  scenario "Admin views the imports index" do
    pending_eligibility_import = create(:npq_application_eligibility_import, :pending)
    completed_eligibility_import = create(:npq_application_eligibility_import, :completed)
    failed_eligibility_import = create(:npq_application_eligibility_import, :failed)

    given_i_sign_in_as_an_admin_user

    visit the_npq_applications_imports_page

    expect(page).to have_content(pending_eligibility_import.filename)
    expect(page).to have_content("Pending")

    expect(page).to have_content(completed_eligibility_import.filename)
    expect(page).to have_content("Completed")
    expect(page).to have_link("View Results", href: admin_npq_applications_eligibility_import_path(completed_eligibility_import))

    expect(page).to have_content(failed_eligibility_import.filename)
    expect(page).to have_content("Failed")
    expect(page).to have_link("View Errors", href: admin_npq_applications_eligibility_import_path(failed_eligibility_import))

    then_the_page_is_accessible

    visit admin_npq_applications_eligibility_import_path(failed_eligibility_import)
    expect(page).to have_content(failed_eligibility_import.filename)
    expect(page).to have_content("Failed")
    failed_eligibility_import.import_errors.each do |error|
      expect(page).to have_content(error)
    end
    expect(page).to have_content("Updated Records -")

    then_the_page_is_accessible

    visit admin_npq_applications_eligibility_import_path(completed_eligibility_import)
    expect(page).to have_content(completed_eligibility_import.filename)
    expect(page).to have_content("Completed")
    expect(page).to have_content("Updated Records #{completed_eligibility_import.updated_records}")
    then_the_page_is_accessible
  end

  scenario "Admin enqueues an import" do
    given_there_is_an_npq_application
    and_i_am_signed_in_as_an_admin

    when_i_visit the_npq_applications_import_page

    when_i_fill_in :"npq-applications-eligibility-import-filename-field", with: "file.csv"

    expect {
      when_i_click_the_button_labelled("Schedule Import")
    }.to have_enqueued_job(
      Admin::NPQApplications::EligibilityImportJob,
    ).with { |npq_application_import|
      expect(npq_application_import.user).to eq @logged_in_admin_user
      expect(npq_application_import.filename).to eq "file.csv"
    }

    expect(
      NPQApplications::EligibilityImport.find_by(
        user: @logged_in_admin_user,
        filename: "file.csv",
      ),
    ).to be_present

    then_i_should_be_on the_npq_applications_imports_page
    and_the_page_should_be_accessible
    and_there_should_be_a_success_banner
  end

  scenario "Admin enters no filename" do
    given_there_is_an_npq_application
    and_i_am_signed_in_as_an_admin

    when_i_visit the_npq_applications_import_page

    expect {
      when_i_click_the_button_labelled("Schedule Import")
    }.to_not have_enqueued_job(Admin::NPQApplications::EligibilityImportJob)

    expect(NPQApplications::EligibilityImport.any?).to be_falsey

    then_i_should_be_on the_npq_applications_imports_page
    and_the_page_should_be_accessible

    then_i_see_an_error_message("Filename can't be blank")
  end

private

  def given_there_is_an_npq_application
    @given_there_is_an_npq_application ||= create(:npq_application)
  end

  def the_npq_applications_import_page
    new_admin_npq_applications_eligibility_import_path
  end

  def the_npq_applications_imports_page
    admin_npq_applications_eligibility_imports_path
  end
end
