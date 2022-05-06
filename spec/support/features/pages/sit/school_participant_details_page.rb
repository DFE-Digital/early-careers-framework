# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolParticipantDetailsPage < ::Pages::BasePage
    set_url "/schools/{slug}/cohorts/{cohort}/participants/{participant_id}"
    # this is a hack as the participants name is the page title
    set_primary_heading(/^.*$/)

    def has_participant_name?(participant_name)
      primary_heading.has_content? participant_name
    end

    def has_email?(email)
      has_text?("Email address #{email}")
    end

    def has_full_name?(full_name)
      has_text?("Full name #{full_name}")
    end

    def has_status?(status)
      has_text?("Status\n#{status}")
    end
  end
end
