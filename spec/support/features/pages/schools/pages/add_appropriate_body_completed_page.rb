# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddAppropriateBodyCompletedPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/appropriate-body/confirm?confirmation_type=add"
        set_primary_heading("Appropriate body reported")

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
