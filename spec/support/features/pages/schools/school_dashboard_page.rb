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

    # Remove this code when we remove FeatureFlag.active?(:cohortless_dashboard) - start
    def confirm_has_participants
      element_has_content? self, "View your early career teacher and mentor details"
    end
    # Remove this code when we remove FeatureFlag.active?(:cohortless_dashboard) - end

    def confirm_has_no_participants
      element_has_content?(self, FeatureFlag.active?(:cohortless_dashboard) ? "ECTs0" : "ECTs and mentors0")
    end

    def confirm_will_use_dfe_funded_training_provider
      element_has_content? self, "Programme Use a training provider funded by the DfE"
    end

    def confirm_is_using_dfe_accredited_materials
      element_has_content? self, "Programme DfE-accredited materials"
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
      if FeatureFlag.active?(:cohortless_dashboard)
        click_on("Manage mentors and ECTs")
      elsif has_link?("Manage participants")
        click_on("Manage participants")
      else
        click_on("Add participants")
      end

      Pages::SchoolParticipantsDashboardPage.loaded
    end

    def add_participant_details
      if FeatureFlag.active?(:cohortless_dashboard)
        click_on("Manage mentors and ECTs")
      elsif has_content?("ECTs and mentors0")
        click_on("Add participants")
      else
        click_on("Manage participants")
      end

      Pages::SchoolParticipantsDashboardPage.loaded
    end
  end
end
