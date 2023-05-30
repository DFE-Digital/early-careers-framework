# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddEctReportFullNamePage < ::Pages::BasePage
        set_url "/schools/{slug}/participants/who/name"
        set_primary_heading "What’s this ECT’s full name?"

        def report_full_name(full_name)
          fill_in "What’s this ECT’s full name?", with: full_name
          click_on "Continue"

          ::Pages::Schools::Pages::AddEctReportTrnPage.loaded
        end
      end
    end
  end
end
