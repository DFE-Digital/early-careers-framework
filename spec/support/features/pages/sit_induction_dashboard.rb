# frozen_string_literal: true

module Pages
  class SITInductionDashboard
    include Capybara::DSL

    def has_expected_content?(sit)
      full_name = sit.user.full_name
      school = sit.schools.first
      partnership = school.partnerships.first

      has_selector?("h1", text: "Manage your training") &&
        has_text?("Induction tutor #{full_name}") &&
        if partnership.nil?
          has_text?("Use DfE-accredited materials") &&
            has_text?("Materials Add") &&
            !has_text?("Training partner") &&
            !has_text?("Delivery partner")
        else
          has_text?("Training provider #{partnership.lead_provider.name}") &&
            has_text?("Delivery partner #{partnership.delivery_partner.name}")
        end
    end

    def has_participants?
      has_text?("View your early career teacher and mentor details") &&
        !has_selector?("a.govuk-link", text: "Add your early career teacher and mentor details")
    end

    def navigate_to_participants_dashboard
      click_on("View your early career teacher and mentor details")

      Pages::ParticipantsDashboard.new
    end
  end
end
