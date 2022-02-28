# frozen_string_literal: true

module Pages
  class FipInductionDashboard
    include Capybara::DSL
    include RSpec::Matchers

    def initialize(sit)
      school = sit.schools.first
      lead_provider = school.partnerships.first.lead_provider
      delivery_partner = school.partnerships.first.delivery_partner

      expect(page).to have_selector("h1", text: "Manage your training")
      expect(page).to have_text("Induction tutor #{sit.user.full_name}")
      expect(page).to have_text("Training provider #{lead_provider.name}")
      expect(page).to have_text("Delivery partner #{delivery_partner.name}")
    end

    def check_has_participants
      expect(page).to have_text "View your early career teacher and mentor details"

      expect(page).to_not have_selector "a.govuk-link",
                                        text: "Add your early career teacher and mentor details"

      self
    end

    def check_has_no_participants
      expect(page).to_not have_text "View your early career teacher and mentor details"

      expect(page).to have_selector "a.govuk-link",
                                    text: "Add your early career teacher and mentor details"

      self
    end

    def navigate_to_participants_dashboard
      click_on("View your early career teacher and mentor details")

      Pages::ParticipantsDashboard.new
    end
  end
end
