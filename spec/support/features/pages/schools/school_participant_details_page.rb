# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantDetailsPage < ::Pages::BasePage
    set_url "/schools/{slug}/participants/{participant_id}"
    set_primary_heading(/^.*$/)

    def confirm_the_participant(name:)
      has_primary_heading? name
    end

    def confirm_email_address(email)
      element_has_content? self, "Email address #{email}"
    end

    def confirm_full_name(full_name)
      element_has_content? self, "Name #{full_name}"
    end

    def confirm_status(status)
      element_has_content? self, "Status\n#{status}"
    end
  end
end
