# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class SetupNextAcademicYearMakeChangesPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/setup/what-changes"
        set_primary_heading "What changes would you like to make?"

        def report_change_to_fip
          choose "Use a training provider, funded by the DfE"
          click_button "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearConfirmChangesPage.loaded
        end

        def report_change_to_cip
          choose "Deliver your own programme using DfE-accredited materials"
          click_button "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearConfirmChangesPage.loaded
        end

        def report_change_fip_provider
          choose "Form new partnership with a lead provider and delivery partner"
          click_button "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearConfirmNewProviderPage.loaded
        end

        def report_change_to_diy
          choose "Design and deliver your own programme based on the Early Career Framework (ECF)"
          click_button "Continue"

          ::Pages::Schools::Pages::SetupNextAcademicYearConfirmRunOwnPage.loaded
        end
      end
    end
  end
end
