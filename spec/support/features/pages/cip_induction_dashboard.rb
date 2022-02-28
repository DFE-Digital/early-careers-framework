# frozen_string_literal: true

module Pages
  class CipInductionDashboard
    include Capybara::DSL
    include RSpec::Matchers

    def initialize(sit)
      expect(page).to have_selector("h1", text: "Manage your training")
      expect(page).to have_text("Induction tutor #{sit.user.full_name}")
      expect(page).to have_text("Use DfE-accredited materials")
      expect(page).to have_text("Materials Add")
      expect(page).to_not have_text("Delivery partner")
      expect(page).to_not have_text("Delivery partner")
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
