# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class SetupNextAcademicYearExpectEctsPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/setup/expect-any-ects"
        set_primary_heading "Does your school expect any new ECTs in the new academic year?"

        def report_expecting_ects
          choose "Yes"
          click_on "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearRunTrainingPage.loaded
        end

        def report_expecting_ects_again
          choose "Yes"
          click_on "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearKeepProviderPage.loaded
        end

        def report_no_ects
          choose "No"
          click_on "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearNoEctsPage.loaded
        end
      end
    end
  end
end
