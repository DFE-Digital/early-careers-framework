# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class FinanceParticipantDrilldown < ::Pages::BasePage
    set_url "/finance/participants/{lead_provider_id}"
    set_primary_heading "Participant"

    def has_participant?(user_id)
      element_has_content? self, "User ID / Participant ID#{user_id}"
    end

    def has_school_urn?(school_urn)
      element_has_content? self, "School URN#{school_urn}"
    end

    def has_lead_provider?(lead_provider_name)
      element_has_content? self, "Lead provider#{lead_provider_name}"
    end

    def has_status?(status)
      element_has_content? self, "Status#{status}"
    end

    def has_training_status?(training_status)
      element_has_content? self, "Training status#{training_status}"
    end

    def has_schedule_identifier?(schedule)
      element_has_content? self, "Schedule identifier#{schedule}"
    end

    def has_schedule_cohort?(cohort)
      element_has_content? self, "Schedule cohort#{cohort}"
    end

    def has_declaration?(declaration_type, course_identifier, state)
      element_has_content? self, "Declaration type#{declaration_type.to_s.gsub('_', '-')}"
      element_has_content? self, "Course identifier#{course_identifier}"
      element_has_content? self, "State#{state}"
    end
  end
end
