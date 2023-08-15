# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class FinanceParticipantDrilldown < ::Pages::BasePage
    set_url "/finance/participants/{user_id}"
    set_primary_heading "Participant"

    def has_participant_id?(user_id)
      element_has_content? self, "User ID / Participant ID#{user_id}"
    end

    def has_profile_id?(profile_id)
      element_has_content? self, "Profile ID#{profile_id}"
    end

    def has_external_id?(external_id)
      element_has_content? self, "External ID#{external_id}"
    end

    def has_full_name?(full_name)
      element_has_content? self, "Full name#{full_name}"
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

    def has_induction_status?(induction_status)
      element_has_content? self, "Induction status#{induction_status}"
    end

    def has_training_programme?(training_programme)
      element_has_content? self, "Training programme#{training_programme}"
    end

    def eligible_for_funding?
      element_has_content? self, "Eligible for fundingTRUE"
    end

    def not_eligible_for_funding?
      element_has_content? self, "Eligible for funding"
      element_without_content? self, "Eligible for fundingTRUE"
    end

    def has_participant_class?(class_name)
      element_has_content? self, class_name
    end

    def has_schedule_identifier?(schedule)
      element_has_content? self, "Schedule identifier#{schedule}"
    end

    def has_schedule?(schedule)
      element_has_content? self, "Schedule#{schedule}"
    end

    def has_schedule_cohort?(cohort)
      element_has_content? self, "Schedule cohort#{cohort}"
    end

    def has_declaration?(declaration_type, course_identifier, state)
      element_has_content? self, "Declaration type#{declaration_type.to_s.gsub('_', '-')}"
      element_has_content? self, "Course identifier#{course_identifier}"
      element_has_content? self, "State#{state}"
    end

    def has_npq_application_id?(application_id)
      element_has_content? self, "Application ID#{application_id}"
    end

    def has_npq_lead_provider?(lead_provider_name)
      element_has_content? self, "Lead Provider#{lead_provider_name}"
    end

    def has_npq_application_status?(npq_application_status)
      element_has_content? self, "Lead Provider approval status#{npq_application_status}"
    end

    def has_npq_course_name?(npq_course_name)
      element_has_content? self, "NPQ course#{npq_course_name}"
    end

    def has_school_ukprn?(school_ukprn)
      element_has_content? self, "School UKPRN#{school_ukprn}"
    end
  end
end
