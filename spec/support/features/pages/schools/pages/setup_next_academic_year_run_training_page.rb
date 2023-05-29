# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class SetupNextAcademicYearRunTrainingPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/setup/how-will-you-run-training"
        set_primary_heading(/\AHow do you want to run your training in (.*)\?\z/)

        def has_correct_academic_year?(academic_year = Cohort.current)
          element_has_content?(header, "How do you want to run your training in #{academic_year.description}?")
        end

        def report_choose_cip
          choose "Deliver your own programme using DfE-accredited materials"
          click_button "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearConfirmProgrammePage.loaded
        end

        def report_choose_fip
          choose "Use a training provider, funded by the DfE"
          click_button "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearConfirmProgrammePage.loaded
        end

        def report_choose_diy
          choose "Design and deliver your own programme based on the early career framework (ECF)"
          click_button "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearConfirmProgrammePage.loaded
        end
      end
    end
  end
end
