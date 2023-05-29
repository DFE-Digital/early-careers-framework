# frozen_string_literal: true

module Pages
  module Schools
    module Wizards
      class SetupNextAcademicYearWizard < ::Pages::BaseWizard
        set_start_page ::Pages::Schools::Pages::SetupNextAcademicYearStartPage

        def choose_cip(appropriate_body: nil)
          start_page.loaded
                    .continue_to_choose_programme
                    .report_expecting_ects
                    .report_choose_cip
                    .confirm_training_programme
                    .confirm_appointed_appropriate_body(appointed: appropriate_body.present?)
        end

        def choose_fip(appropriate_body: nil)
          start_page.loaded
                    .continue_to_choose_programme
                    .report_expecting_ects
                    .report_choose_fip
                    .confirm_training_programme
                    .confirm_appointed_appropriate_body(appointed: appropriate_body.present?)
        end

        def choose_diy(appropriate_body: nil)
          start_page.loaded
                    .continue_to_choose_programme
                    .report_expecting_ects
                    .report_choose_diy
                    .confirm_training_programme
                    .confirm_appointed_appropriate_body(appointed: appropriate_body.present?)
        end

        def choose_no_ects
          start_page.loaded
                    .continue_to_choose_programme
                    .report_no_ects
        end

        # second academic year if after a FIP academic year

        def choose_fip_keep_previous(appropriate_body: nil)
          start_page.loaded
                    .continue_to_choose_programme
                    .report_expecting_ects_again
                    .report_use_same
                    .confirm_appointed_appropriate_body(appointed: appropriate_body.present?)
        end

        def choose_cip_change_provider(appropriate_body: nil)
          start_page.loaded
                    .continue_to_choose_programme
                    .report_expecting_ects_again
                    .report_use_different
                    .report_change_to_cip
                    .confirm_training_programme
                    .confirm_appointed_appropriate_body(appointed: appropriate_body.present?)
        end

        def choose_fip_change_provider(appropriate_body: nil)
          start_page.loaded
                    .continue_to_choose_programme
                    .report_expecting_ects_again
                    .report_use_different
                    .report_change_fip_provider
                    .confirm_training_programme
                    .confirm_appointed_appropriate_body(appointed: appropriate_body.present?)
        end

        def choose_diy_change_provider(appropriate_body: nil)
          start_page.loaded
                    .continue_to_choose_programme
                    .report_expecting_ects_again
                    .report_use_different
                    .report_change_to_diy
                    .confirm_training_programme
                    .confirm_appointed_appropriate_body(appointed: appropriate_body.present?)
        end
      end
    end
  end
end
