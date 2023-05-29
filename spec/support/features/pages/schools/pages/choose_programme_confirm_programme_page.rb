# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class ChooseProgrammeConfirmProgrammePage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/choose-programme/confirm-programme"
        set_primary_heading "Confirm your training programme"

        def confirm_training_programme
          click_on "Confirm"

          ::Pages::Schools::Pages::ChooseProgrammeAppropriateBodyAppointedPage.loaded
        end

        def confirm_no_training_programme
          click_on "Confirm"

          ::Pages::Schools::Pages::ChooseProgrammeCompletedPage.loaded
        end
      end
    end
  end
end
