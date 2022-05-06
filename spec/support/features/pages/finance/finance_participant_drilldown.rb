# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class FinanceParticipantDrilldown < ::Pages::BasePage
    set_url "/finance/participants/{lead_provider_id}"
    set_primary_heading "Participant"

    def has_participant?(user_id)
      has_content? "User ID / Participant ID#{user_id}"
    end

    def has_school_urn?(school_urn)
      has_content?("School URN#{school_urn}")
    end

    def has_lead_provider?(lead_provider_name)
      has_content?("Lead provider#{lead_provider_name}")
    end

    def has_status?(status)
      has_content?("Status#{status}")
    end

    def has_training_status?(training_status)
      has_content?("Training status#{training_status}")
    end

    def has_schedule_identifier?(schedule)
      has_content?("Schedule identifier#{schedule}")
    end

    def has_schedule_cohort?(cohort)
      has_content?("Schedule cohort#{cohort}")
    end

    def has_declaration?(declaration_type, course_identifier, state)
      has_content?("Declaration type#{declaration_type}") &&
        has_content?("Course identifier#{course_identifier}") &&
        has_content?("State#{state}")
    end
  end
end
