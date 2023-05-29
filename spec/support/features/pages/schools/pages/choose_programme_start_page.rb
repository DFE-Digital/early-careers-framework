# frozen_string_literal: true

module Pages
  module Schools
    module Pages
      class ChooseProgrammeStartPage < ::Pages::BasePage
        set_url "/schools/{slug}/cohorts/{cohort}/choose-programme"
        set_primary_heading(/\AHow do you want to run your training in (.*)\?\z/)

        def has_correct_academic_year?(academic_year = Cohort.current)
          element_has_content?(header, "How do you want to run your training in #{academic_year.description}?")
        end

        def report_how_training_will_run(programme_type: nil)
          programme_type = programme_type.downcase.to_sym if programme_type.is_a?(String)

          case programme_type
          when :fip
            choose "Use a training provider, funded by the DfE (full induction programme)"
          when :cip
            choose "Deliver your own programme using DfE accredited materials"
          when :diy
            choose "Design and deliver your own programme based on the Early Career Framework (ECF)"
          when :none
            choose "We do not expect any early career teachers to join"
          else
            raise ArgumentError, "expected programme_type to be one of :fip, :cip, :diy or :none but got #{programme_type}"
          end

          click_button "Continue"

          ::Pages::Schools::Pages::ChooseProgrammeConfirmProgrammePage.loaded
        end
      end
    end
  end
end
