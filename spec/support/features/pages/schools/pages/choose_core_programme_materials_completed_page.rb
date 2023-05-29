# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class ChooseCoreProgrammeMaterialsCompletedPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/core-programme/materials/success"
        set_primary_heading "Training materials confirmed"

        def has_correct_academic_year?(academic_year = Cohort.current)
          element_has_content?(header, "Academic year #{academic_year.description}")
        end

        def return_to_manage_training
          click_on "Return to manage your training"

          ::Pages::Schools::Dashboards::ManageYourTrainingDashboard.loaded
        end
      end
    end
  end
end
