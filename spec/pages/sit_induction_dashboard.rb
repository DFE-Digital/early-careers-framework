# frozen_string_literal: true

module Pages
  class SITInductionDashboard
    include Capybara::DSL

    def has_expected_content?(sit)
      full_name = sit.user.full_name
      school = sit.schools.first
      partnership = school.partnerships.first

      has_text?("Manage your training") &&
        has_text?("Induction tutor #{full_name}") &&
        if partnership.nil?
          has_text?("Programme Use DfE-accredited materials")
        else
          has_text?("Programme Use a training provider funded by the DfE")
        end
    end

    def has_participants?
      has_text?("View your early career teacher and mentor details") &&
        !has_selector?("a.govuk-link", text: "Add your early career teacher and mentor details")
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
