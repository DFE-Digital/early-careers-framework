# frozen_string_literal: true

module Pages
  module Schools
    module Wizards
      class AddEctWizard < ::Pages::BaseWizard
        set_start_page ::Pages::Schools::Pages::AddEctStartPage

        def report_details(full_name:, trn:, date_of_birth:, email_address:, start_term:)
          start_page.loaded
                    .start_add_ect_wizard
                    .report_full_name(full_name)
                    .report_trn(full_name, trn)
                    .report_date_of_birth(date_of_birth)
                    .report_email_address(full_name, email_address)
                    .report_start_term(start_term)
                    .confirm_and_add
        end

        def report_with_appropriate_body(full_name:, trn:, date_of_birth:, email_address:, start_term:)
          start_page.loaded
                    .start_add_ect_wizard
                    .report_full_name(full_name)
                    .report_trn(full_name, trn)
                    .report_date_of_birth(date_of_birth)
                    .report_email_address(full_name, email_address)
                    .report_start_term(start_term)
                    .confirm_appropriate_body(confirm: true)
                    .confirm_and_add
        end

        def confirm_expects_more_information(full_name:, trn:, date_of_birth:, email_address:, start_term:)
          start_page.loaded
                    .start_add_ect_wizard
                    .report_full_name(full_name)
                    .report_trn(full_name, trn)
                    .report_date_of_birth(date_of_birth)
                    .report_email_address(full_name, email_address)
                    .report_start_term(start_term)
        end
      end
    end
  end
end
