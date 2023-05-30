# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddEctReportAppropriateBodyPage < ::Pages::BasePage
        set_url "/schools/{slug}/participants/add/confirm-appropriate-body"
        set_primary_heading(/Is this the appropriate body for (.*) induction\?/)

        def has_correct_full_name?(full_name)
          element_has_content?(header, "Is this the appropriate body for #{full_name} induction?")
        end

        def has_correct_appropriate_body_name?(appropriate_body_name)
          element_has_content? self, appropriate_body_name
        end

        def confirm_appropriate_body(confirm: true)
          if confirm
            click_on "Confirm"

            ::Pages::Schools::Pages::AddEctCheckAnswersPage.loaded
          else
            click_on "They have a different appropriate body"

            full_stop
          end
        end
      end
    end
  end
end
