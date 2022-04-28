# frozen_string_literal: true

require_relative "../base"

module Pages
  class SchoolPage < ::Pages::Base
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

      has_text? "Induction tutor #{full_name}"
    end

    def has_participants?
      has_text?("View your early career teacher and mentor details") &&
        !has_selector?("a.govuk-link", text: "Add your early career teacher and mentor details")
    end

    def has_partnership?
      has_text? "Programme Use a training provider funded by the DfE"
    end

    def has_no_partnership?
      has_text? "Programme Use DfE-accredited materials"
    end

    def view_programme_details
      has_partnership?
      click_on "View details"

      Pages::SchoolCohortsPage.loaded
    end

    def report_school_has_been_confirmed_incorrectly
      has_no_partnership?
      click_on "report that your school has been confirmed incorrectly"

      Pages::ReportIncorrectPartnershipPage.loaded
    end

    def view_participant_dashboard
      click_on "View your early career teacher and mentor details"

      Pages::SITParticipantsDashboard.new
    end

    def start_add_participant_wizard
      click_on "Add your early career teacher and mentor details"

      Pages::SITAddParticipantWizard.new
    end

    def start_transfer_participant_wizard
      click_on "Add your early career teacher and mentor details"

      Pages::SITTransferParticipantWizard.new
    end
  end
end
