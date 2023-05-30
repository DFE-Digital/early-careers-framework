# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddEctReportTrnPage < ::Pages::BasePage
        set_url "/schools/{slug}/participants/who/trn"
        set_primary_heading(/What’s (.*) teacher reference number \(TRN\)\?/)

        def has_correct_full_name?(full_name)
          element_has_content?(header, "What’s #{possessive_name(full_name)} teacher reference number (TRN)?")
        end

        def report_trn(full_name, trn)
          fill_in "What’s #{possessive_name(full_name)} teacher reference number (TRN)?", with: trn
          click_on "Continue"

          ::Pages::Schools::Pages::AddEctReportDateOfBirthPage.loaded
        end
      end
    end
  end
end
