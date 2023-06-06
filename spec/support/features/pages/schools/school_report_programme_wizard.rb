# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolReportProgrammeWizard < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/setup"
    set_primary_heading "What we need to know"

    def complete(programme_type)
      click_on "Continue"
      choose "Yes"
      click_button "Continue"
      choose_programme_type programme_type
      click_button "Confirm"
      choose "No"
      click_button "Continue"
    end

    def choose_programme_type(programme_type)
      case programme_type.downcase.to_sym
      when :fip
        choose "Use a training provider, funded by the DfE"
      when :cip
        choose "Deliver your own programme using DfE-accredited materials"
      when :diy
        choose "Design and deliver your own programme based on the Early Career Framework (ECF)"
      end
      click_button "Continue"
    end
  end
end
