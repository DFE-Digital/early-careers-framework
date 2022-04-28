# frozen_string_literal: true

module Pages
  class LeadProviderDashboard
    include Capybara::DSL

    def start_confirm_your_schools_wizard
      click_on "Confirm your schools"

      Pages::LeadProviderConfirmYourSchoolsWizard.new
    end
  end
end
