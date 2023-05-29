# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class SetupNextAcademicYearKeepProviderPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/setup/keep-providers"
        set_primary_heading "Do you want to use the same lead provider and delivery partner for your new ECTs?"

        def report_use_same
          choose "Yes"
          click_on "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearAppropriateBodyAppointedPage.loaded
        end

        def report_use_different
          choose "No"
          click_on "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearMakeChangesPage.loaded
        end
      end
    end
  end
end
