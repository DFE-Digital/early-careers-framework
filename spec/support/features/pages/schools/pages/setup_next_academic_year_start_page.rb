# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class SetupNextAcademicYearStartPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/setup"
        set_primary_heading "What we need to know"

        def continue_to_choose_programme
          click_on "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearExpectEctsPage.loaded
        end
      end
    end
  end
end
