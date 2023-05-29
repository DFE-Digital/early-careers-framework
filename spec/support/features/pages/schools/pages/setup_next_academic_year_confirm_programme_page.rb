# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class SetupNextAcademicYearConfirmProgrammePage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/setup/programme-confirmation"
        set_primary_heading "Are you sure this is how you want to run your training?"

        def confirm_training_programme
          click_on "Confirm"

          ::Pages::Schools::Pages::SetupNextAcademicYearAppropriateBodyAppointedPage.loaded
        end
      end
    end
  end
end
