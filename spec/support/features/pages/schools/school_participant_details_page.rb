# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantDetailsPage < ::Pages::BasePage
    set_url "/schools/{slug}/participants/{participant_id}"
    set_primary_heading(/^.*$/)

    def has_participant_name?(full_name)
      has_primary_heading? full_name
    end
    alias_method :confirm_participant_name, :has_participant_name?

    def has_email?(email)
      element_has_content? self, "Email address #{email}"
    end
    alias_method :has_email_address?, :has_email?
    alias_method :confirm_email_address, :has_email?
    alias_method :confirm_email, :has_email?

    def has_full_name?(full_name)
      element_has_content? self, "Name #{full_name}"
    end
    alias_method :confirm_full_name, :has_full_name?

    def has_status?(status)
      element_has_content? self, "Status #{status}"
    end
    alias_method :confirm_status, :has_status?
  end
end
