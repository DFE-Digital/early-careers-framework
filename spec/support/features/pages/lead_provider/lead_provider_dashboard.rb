# frozen_string_literal: true

require_relative "../base"

module Pages
  class LeadProviderDashboard < ::Pages::Base
    include Capybara::DSL

    def start_confirm_your_schools_wizard
      click_on "Confirm your schools"

      Pages::LeadProviderConfirmYourSchoolsWizard.new
    end
  end
end
