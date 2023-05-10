# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolReportProgrammeCompletedPage < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/choose-programme/success"
    set_primary_heading "You’ve submitted your training information"

    def continue_to_manage_your_training
      click_on "Continue to manage your training"

      Pages::SchoolDashboardPage.loaded
    end
  end
end
