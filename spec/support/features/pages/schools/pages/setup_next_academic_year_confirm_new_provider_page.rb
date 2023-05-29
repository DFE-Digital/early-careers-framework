# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class SetupNextAcademicYearConfirmNewProviderPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/setup/what-changes-confirmation"
        set_primary_heading "You are going to form a new partnership with a lead provider"

        def confirm_training_programme
          click_on "Confirm"

          ::Pages::Schools::Pages::SetupNextAcademicYearAppropriateBodyAppointedPage.loaded
        end
      end
    end
  end
end
