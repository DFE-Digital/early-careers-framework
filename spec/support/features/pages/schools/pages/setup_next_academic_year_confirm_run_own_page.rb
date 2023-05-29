# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class SetupNextAcademicYearConfirmRunOwnPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/setup/what-changes-confirmation"
        set_primary_heading "Are you sure you want to run your own training programme?"

        def confirm_training_programme
          click_on "Confirm"

          ::Pages::Schools::Pages::SetupNextAcademicYearAppropriateBodyAppointedPage.loaded
        end
      end
    end
  end
end
