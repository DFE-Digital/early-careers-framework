# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddAppropriateBodyChoosePage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/appropriate-body/appropriate-body"
        set_primary_heading(/Which (.*) have you appointed\?\z/)

        def report_appropriate_body_name(name = "")
          select name
          click_on "Continue"

          ::Pages::Schools::Pages::AddAppropriateBodyCompletedPage.loaded
        end
      end
    end
  end
end
