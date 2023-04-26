# frozen_string_literal: true

require_relative "../../base_page"

module Pages
  class SchoolFundedFipTrainingSubmittedPage < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/setup/complete"
    set_primary_heading(/\AYou’ve submitted your training information\z/)

    def can_get_guidance_about_an_arrangement_with_a_training_provider
      has_link?("make your own arrangements with a training provider (opens in a new tab)")
    end

    def can_email_cpd_for_help
      has_link?(href: "mailto:continuing-professional-development@digital.education.gov.uk")
    end
  end
end
