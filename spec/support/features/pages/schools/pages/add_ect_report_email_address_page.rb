# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddEctReportEmailAddressPage < ::Pages::BasePage
        set_url "/schools/{slug}/participants/add"
        set_primary_heading(/What’s (.*) email address\?/)

        def has_correct_full_name?(full_name)
          element_has_content?(header, "What’s #{possessive_name(full_name)} email address?")
        end

        def report_email_address(full_name, participant_email)
          fill_in "What’s #{possessive_name(full_name)} email address?", with: participant_email
          click_on "Continue"

          ::Pages::Schools::Pages::AddEctReportStartTermPage.loaded
        end
      end
    end
  end
end
