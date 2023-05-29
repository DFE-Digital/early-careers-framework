# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class SetupNextAcademicYearCompletedPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/setup/complete"
        set_primary_heading "You’ve submitted your training information"

        def continue_to_manage_training
          click_on "Continue to manage your training"

          ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
        end
      end
    end
  end
end
