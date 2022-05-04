# frozen_string_literal: true

require_relative "../base"

module Pages
  class FinanceParticipantDrilldown < ::Pages::Base
    set_url "/finance/participants/{lead_provider_id}"
    set_primary_heading "Participant"

    def can_see_participant?(user_id)
      has_text?("User ID / Participant ID #{user_id}")
    end

    def can_see_school_urn?(school_urn)
      has_text?("School URN#{school_urn}")
    end

    def can_see_lead_provider_urn?(lead_provider_name)
      has_text?("Lead provider#{lead_provider_name}")
    end

    def can_see_status?(status)
      has_text?("Status#{status}")
    end

    def can_see_training_status?(training_status)
      has_text?("Training status#{training_status}")
    end

    def can_see_schedule_identifier?(schedule)
      has_text?("Schedule identifier#{schedule}")
    end

    def can_see_schedule_cohort?(cohort)
      has_text?("Schedule cohort#{cohort}")
    end

    def can_see_declaration?(declaration_type, course_identifier, state)
      has_text?("Declaration type#{declaration_type}")
      has_text?("Course identifier#{course_identifier}")
      has_text?("State#{state}")
    end
  end
end
