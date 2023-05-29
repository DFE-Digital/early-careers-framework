# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class ChooseCoreProgrammeMaterialsStartPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/core-programme/materials/info"
        set_primary_heading "Do you know which accredited materials you want to use?"

        def continue
          click_on "Continue"

          ::Pages::Schools::Pages::ChooseCoreProgrammeMaterialsChangePage.loaded
        end
      end
    end
  end
end
