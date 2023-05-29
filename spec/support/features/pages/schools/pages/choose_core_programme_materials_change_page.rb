# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class ChooseCoreProgrammeMaterialsChangePage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/core-programme/materials/edit"
        set_primary_heading "Which training materials do you want to use?"

        def choose_core_programme_materials(name: "")
          choose name
          click_on "Continue"

          ::Pages::Schools::Pages::ChooseCoreProgrammeMaterialsCompletedPage.loaded
        end
      end
    end
  end
end
