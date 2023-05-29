# frozen_string_literal: true

module Pages
  module Schools
    module Wizards
      class ChooseAppropriateBodyWizard < ::Pages::BaseWizard
        set_start_page ::Pages::Schools::Pages::AddAppropriateBodyStartPage

        def report_appropriate_body(appropriate_body:)
          start_page.loaded
                    .report_appropriate_body_type(appropriate_body.body_type)
                    .report_appropriate_body_name(appropriate_body.name)
        end
      end
    end
  end
end
