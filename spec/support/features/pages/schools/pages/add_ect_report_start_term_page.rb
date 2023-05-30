# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddEctReportStartTermPage < ::Pages::BasePage
        set_url "/schools/{slug}/participants/add/start-term"
        set_primary_heading(/When will (.*) start their induction\?/)

        def has_correct_full_name?(full_name)
          element_has_content?(header, "When will #{full_name} start their induction?")
        end

        def report_start_term(start_term)
          choose start_term
          click_on "Continue"

          next_page
        end

      private

        def next_page
          page = [
            ::Pages::Schools::Pages::AddEctNeedMoreInformationPage,
            ::Pages::Schools::Pages::AddEctReportAppropriateBodyPage,
            ::Pages::Schools::Pages::AddEctCheckAnswersPage,
          ].find(&:displayed?)

          raise "Unexpected next page: #{url}" if page.blank?

          page.loaded
        end
      end
    end
  end
end
