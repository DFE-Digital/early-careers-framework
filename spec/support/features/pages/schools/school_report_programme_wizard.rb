# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolReportProgrammeWizard < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/choose-programme"
    set_primary_heading "How do you want to run your training in 2021 to 2022?"

    def complete(programme_type)
      choose_programme_type programme_type
      click_button "Confirm"
      choose "No"
      click_button "Continue"
    end

    def choose_programme_type(programme_type)
      if FeatureFlag.active?(:programme_type_changes_2025)
        case programme_type.downcase.to_sym
        when :fip
          choose "Provider-led"
        when :cip
          choose "School-led"
        when :diy
          choose "School-led"
        end
      else
        case programme_type.downcase.to_sym
        when :fip
          choose "Use a training provider, funded by the DfE"
        when :cip
          choose "Deliver your own programme using DfE-accredited materials"
        when :diy
          choose "Design and deliver your own programme based on the early career framework (ECF)"
        end
      end

      click_button "Continue"
    end
  end
end
