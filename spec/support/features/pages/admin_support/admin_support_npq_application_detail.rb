# frozen_string_literal: true

require_relative "../base_page"

module Pages
  # noinspection RubyClassModuleNamingConvention
  class AdminSupportNPQApplicationDetail < ::Pages::BasePage
    set_url "/admin/npq/applications/applications/{application_id}"
    set_primary_heading("NPQ Application")

    def has_preferred_name?(expected_value)
      element_has_content? self, "Preferred name#{expected_value}Change"
    end

    def has_email_address?(expected_value)
      element_has_content? self, "Email#{expected_value}Change"
    end

    def has_application_id?(expected_value)
      element_has_content? self, "Application ID#{expected_value}"
    end

    def has_user_id?(expected_value)
      element_has_content? self, "User ID#{expected_value}"
    end

    def has_trn?(trn)
      element_has_content? self, "TRN#{trn}"
    end

    def has_schedule_cohort?(expected_value)
      element_has_content? self, "Schedule Cohort#{expected_value}"
    end

    def has_lead_provider?(expected_value)
      element_has_content? self, "Lead provider#{expected_value}"
    end

    def has_application_status?(expected_value)
      element_has_content? self, "Lead provider approval status#{expected_value}"
    end

    def has_course_name?(expected_value)
      element_has_content? self, "Course#{expected_value}"
    end

    def eligible_for_funding?
      element_has_content? self, "Funding eligibilityYES"
    end

    def not_eligible_for_funding?
      element_has_content? self, "Funding eligibilityNO"
    end

    def has_school_urn?(expected_value)
      element_has_content? self, "School URN#{expected_value}View School"
    end

    def has_school_ukprn?(expected_value)
      element_has_content? self, "School UKPRN#{expected_value}"
    end
  end
end
