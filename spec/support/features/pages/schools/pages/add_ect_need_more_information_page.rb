# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class AddEctNeedMoreInformationPage < ::Pages::BasePage
        set_url "/schools/{slug}/participants/add/need-training-setup"
        set_primary_heading("We need some more information")

        def cannot_register_ect?(full_name, academic_year = Cohort.current)
          element_has_content? self, "Before you can register #{full_name} for ECF-based training at your school, you’ll need to set up training for the #{academic_year.description} academic year."
        end

        def continue_to_set_up_training
          click_on "Continue to set up training"

          ::Pages::Schools::Wizards::SetupNextAcademicYearWizard.loaded
        end
      end
    end
  end
end
