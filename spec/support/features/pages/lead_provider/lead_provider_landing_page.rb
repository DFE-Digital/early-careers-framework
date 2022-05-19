# frozen_string_literal: true

require_relative "../base"

module Pages
  class LeadProviderLandingPage < ::Pages::Base
    set_url "/lead-providers"
    set_primary_heading "Manage your records quickly and easily"

    def get_started
      click_on "Get started"

      raise "Not yet implemented"
    end

    def learn_to_manage_ecf_partnerships
      click_on "Learn to manage ECF partnerships"

      raise "Not yet implemented"
    end
  end
end
