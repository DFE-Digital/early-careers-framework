# frozen_string_literal: true

module Pages
  module Schools
    module Wizards
      class AddEctOrMentorWizard < ::Pages::BaseWizard
        set_start_page ::Pages::Schools::Pages::AddEctOrMentorStartPage

        def add_ect(full_name:, trn:, date_of_birth:, email_address:, start_term:)
          start_page.loaded
                    .choose_ect
                    .report_details(full_name:, trn:, date_of_birth:, email_address:, start_term:)
        end

        def add_ect_with_appropriate_body(full_name:, trn:, date_of_birth:, email_address:, start_term:)
          start_page.loaded
                    .choose_ect
                    .report_with_appropriate_body(full_name:, trn:, date_of_birth:, email_address:, start_term:)
        end

        def add_ect_without_enough_information(full_name:, trn:, date_of_birth:, email_address:, start_term:)
          start_page.loaded
                    .choose_ect
                    .confirm_expects_more_information(full_name:, trn:, date_of_birth:, email_address:, start_term:)
        end
      end
    end
  end
end
