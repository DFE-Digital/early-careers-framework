# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolDashboardPage < ::Pages::BasePage
    set_url "/schools/{slug}"
    set_primary_heading "Manage your training"

    def has_induction_tutor(sit)
      full_name = case sit.class
                  when InductionCoordinatorProfile
                    sit.user.full_name
                  when User
                    sit.full_name
                  else
                    sit.to_s
                  end

      has_content? "Induction tutor #{full_name}"
    end

    def has_participants?
      has_content?("View your early career teacher and mentor details") &&
        !has_selector?("a", text: "Add your early career teacher and mentor details")
    end

    def has_partnership?
      has_content? "Programme Use a training provider funded by the DfE"
    end

    def has_no_partnership?
      has_content? "Programme Use DfE-accredited materials"
    end

    def view_programme_details
      has_partnership?
      click_on "View details"

      Pages::SchoolCohortsPage.loaded
    end

    def has_view_programme_details?
      has_partnership?
      has_selector?("a", text: "View details")
    end

    def report_school_has_been_confirmed_incorrectly
      has_no_partnership?
      click_on "report that your school has been confirmed incorrectly"

      Pages::ReportIncorrectPartnershipPage.loaded
    end

    def has_report_school_has_been_confirmed_incorrectly?
      has_no_partnership?
      has_selector?("a", text: "report that your school has been confirmed incorrectly")
    end

    def view_participant_dashboard
      click_on "View your early career teacher and mentor details"

      Pages::SchoolParticipantsDashboardPage.loaded
    end

    def start_add_participant_wizard
      click_on "Add your early career teacher and mentor details"

      Pages::SchoolAddParticipantWizard.loaded
    end

    def start_transfer_participant_wizard
      click_on "Add your early career teacher and mentor details"

      Pages::SchoolTransferParticipantWizard.loaded
    end
  end
end
