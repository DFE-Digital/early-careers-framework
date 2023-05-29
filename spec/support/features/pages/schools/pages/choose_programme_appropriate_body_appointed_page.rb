# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class ChooseProgrammeAppropriateBodyAppointedPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/choose-programme/appropriate-body-appointed"
        set_primary_heading "Have you appointed an appropriate body?"

        def confirm_appointed_appropriate_body(appointed: false)
          if appointed
            choose "Yes"
          else
            choose "No"
          end

          click_on "Continue"

          ::Pages::Schools::Pages::ChooseProgrammeCompletedPage.loaded
        end
      end
    end
  end
end
