# frozen_string_literal: true

require_relative "./base"

module Pages
  class SandboxLandingPage < ::Pages::Base
    include Capybara::DSL

    def initialize
      @url = "/sandbox"
      @title = "Use our sandbox to test Manage teacher CPD"
    end

    def continue_as_an_npq_participant
      click_on "Continue as an NPQ participant"

      raise "Not yet implemented"
    end

    def continue_as_an_ecf_training_provider
      click_on "Continue as an ECF training provider"

      Pages::LeadProviderLandingPage.new
    end

    def review_api_guidance
      click_on "Review our API guidance"

      raise "Not yet implemented"
    end
  end
end
