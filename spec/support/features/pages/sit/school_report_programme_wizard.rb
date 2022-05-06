# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolReportProgrammeWizard < ::Pages::BasePage
    set_url "SITReportProgrammeWizard"
    set_primary_heading "SITReportProgrammeWizard"

    def complete(programme_type)
      choose_programme_type programme_type
      click_button "Confirm"
    end

    def choose_programme_type(programme_type)
      case programme_type.downcase.to_sym
      when :fip
        choose "Use a training provider, funded by the DfE (full induction programme)"
      when :cip
        choose "Deliver your own programme using DfE accredited materials"
      when :diy
        choose "Design and deliver your own programme based on the Early Career Framework (ECF)"
      end
      click_button "Continue"
    end
  end
end
