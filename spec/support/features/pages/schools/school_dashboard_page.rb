# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolDashboardPage < ::Pages::BasePage
    set_url "/schools/{slug}"
    set_primary_heading "Manage your training"

    def has_induction_tutor?(sit)
      full_name = case sit.class
                  when InductionCoordinatorProfile
                    sit.user.full_name
                  when User
                    sit.full_name
                  else
                    sit.to_s
                  end

      element_has_content? self, "Induction tutor #{full_name}"
    end

    def confirm_has_participants
      element_has_content? self, "View your early career teacher and mentor details"
    end

    def confirm_has_no_participants
      element_has_content? self, "Add your early career teacher and mentor details"
    end

    def confirm_participant_is_not_training(participant_name)
      participant_dashboard = view_participant_details
      participant_details = participant_dashboard.view_not_training(participant_name)
      participant_details.confirm_the_participant(name: participant_name)
    end

    def confirm_will_use_dfe_funded_training_provider
      element_has_content? self, "Programme Use a training provider funded by the DfE"
    end

    def confirm_is_using_dfe_accredited_materials
      element_has_content? self, "Programme DfE-accredited materials"
    end

    def view_programme_details
      click_on "View details"

      Pages::SchoolCohortsPage.loaded
    end

    def report_school_has_been_confirmed_incorrectly
      click_on "report that your school has been confirmed incorrectly"

      Pages::ReportIncorrectPartnershipPage.loaded
    end

    def confirm_can_report_school_has_been_confirmed_incorrectly
      element_has_content? self, "report that your school has been confirmed incorrectly"
    end

    def confirm_cannot_report_school_has_been_confirmed_incorrectly
      element_without_content? self, "report that your school has been confirmed incorrectly"
    end

    def view_participant_details
      click_on "View your early career teacher and mentor details"

      Pages::SchoolParticipantsDashboardPage.loaded
    end

    def add_participant_details
      click_on "Add your early career teacher and mentor details"

      Pages::SchoolAddParticipantStartPage.loaded
    end
  end
end
