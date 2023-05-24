# frozen_string_literal: true

require_relative "./base_page"

module Pages
  class SandboxLandingPage < ::Pages::BasePage
    set_url "/sandbox"
    set_primary_heading "Use our sandbox environment"

    def continue_as_an_npq_participant
      click_on "Continue as an NPQ participant"

      raise "Not yet implemented"
    end

    def continue_as_an_ecf_training_provider
      click_on "Login to sandbox as a school induction tutor"

      Pages::LeadProviderLandingPage.loaded
    end

    def review_api_guidance
      click_on "Review our API guidance"

      raise "Not yet implemented"
    end
  end
end
