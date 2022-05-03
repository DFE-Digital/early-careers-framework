# frozen_string_literal: true

module Pages
  class SITReportProgrammeWizard
    include Capybara::DSL

    def complete(programme_type)
      choose_programme_type programme_type
      click_button "Confirm"
    end

    def choose_programme_type(programme_type)
      case programme_type.downcase.to_sym
      when :fip
        choose "Use a training provider, funded by the DfE"
      when :cip
        choose "Deliver your own programme using DfE accredited materials"
      when :diy
        choose "Design and deliver your own programme based on the Early Career Framework (ECF)"
      end
      click_button "Continue"
    end
  end
end
