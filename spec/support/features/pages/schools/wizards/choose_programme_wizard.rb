# frozen_string_literal: true

module Pages
  module Schools
    module Wizards
      class ChooseProgrammeWizard < ::Pages::BaseWizard
        set_start_page ::Pages::Schools::Pages::ChooseProgrammeStartPage

        def choose_cip(appropriate_body: nil)
          start_page.loaded
                    .report_how_training_will_run(programme_type: :cip)
                    .confirm_training_programme
                    .confirm_appointed_appropriate_body(appointed: appropriate_body.present?)
        end

        def choose_fip(appropriate_body: nil)
          start_page.loaded
                    .report_how_training_will_run(programme_type: :fip)
                    .confirm_training_programme
                    .confirm_appointed_appropriate_body(appointed: appropriate_body.present?)
        end

        def choose_diy(appropriate_body: nil)
          start_page.loaded
                    .report_how_training_will_run(programme_type: :diy)
                    .confirm_training_programme
                    .confirm_appointed_appropriate_body(appointed: appropriate_body.present?)
        end

        def choose_no_ects
          start_page.loaded
                    .report_how_training_will_run(programme_type: :none)
                    .confirm_no_training_programme
        end
      end
    end
  end
end
