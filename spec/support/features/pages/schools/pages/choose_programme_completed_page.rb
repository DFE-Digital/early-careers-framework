# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class ChooseProgrammeCompletedPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/choose-programme/success"
        set_primary_heading "You’ve submitted your training information"

        def continue_to_manage_training
          click_on "Continue to manage your training"

          ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
        end
      end
    end
  end
end
