# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddEctReportDateOfBirthPage < ::Pages::BasePage
        set_url "/schools/{slug}/participants/who/date-of-birth"
        set_primary_heading(/What’s (.*) date of birth\?/)

        def has_correct_full_name?(full_name)
          element_has_content?(header, "What’s #{possessive_name(full_name)} date of birth?")
        end

        def report_date_of_birth(date_of_birth)
          fill_in "Day", with: date_of_birth.day
          fill_in "Month", with: date_of_birth.month
          fill_in "Year", with: date_of_birth.year
          click_on "Continue"

          ::Pages::Schools::Pages::AddEctReportEmailAddressPage.loaded
        end
      end
    end
  end
end
