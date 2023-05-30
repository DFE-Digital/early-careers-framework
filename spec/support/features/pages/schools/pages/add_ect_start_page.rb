# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddEctStartPage < ::Pages::BasePage
        set_url "/schools/{slug}/participants/who/what-we-need"
        set_primary_heading "What we need from you"

        def start_add_ect_wizard
          click_on "Continue"

          ::Pages::Schools::Pages::AddEctReportFullNamePage.loaded
        end
      end
    end
  end
end
