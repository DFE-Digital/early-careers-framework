# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class LeadProviderLandingPage < ::Pages::BasePage
    set_url "/lead-providers"
    set_primary_heading "Manage data quickly and easily"

    def get_started
      click_on "Get started"

      raise "Not yet implemented"
    end

    def learn_to_manage_ecf_partnerships
      click_on "How to manage ECF partnerships"

      raise "Not yet implemented"
    end
  end
end
