# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolReportProgrammeWizard < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/choose-programme"
    set_primary_heading(/\AHow do you want to run your training in (.*)\?\z/)

    def confirm_correct_academic_year(academic_year)
      element_has_content?(header, "How do you want to run your training in #{academic_year.description}?")
    end

    def complete(programme_type: "FIP", appropriate_body: nil)
      choose_programme_type programme_type
      click_button "Confirm"

      choose_appropriate_body(appropriate_body) unless programme_type == "NONE"

      Pages::SchoolReportProgrammeCompletedPage.loaded
    end

    def choose_programme_type(programme_type = "NONE")
      case programme_type.downcase.to_sym
      when :fip
        choose "Use a training provider, funded by the DfE (full induction programme)"
      when :cip
        choose "Deliver your own programme using DfE accredited materials"
      when :diy
        choose "Design and deliver your own programme based on the Early Career Framework (ECF)"
      else
        choose "We do not expect any early career teachers to join"
      end

      click_button "Continue"
    end

    def choose_appropriate_body(appropriate_body)
      if appropriate_body.present?
        choose "Yes"
      else
        choose "No"
      end

      click_button "Continue"
    end
  end
end
