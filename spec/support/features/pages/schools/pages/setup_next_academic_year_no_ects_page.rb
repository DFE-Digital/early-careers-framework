# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class SetupNextAcademicYearNoEctsPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/setup/no-expected-ects"
        set_primary_heading "Your information has been saved"

        def continue_to_manage_training
          click_on "Continue to manage your training"

          ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
        end
      end
    end
  end
end
