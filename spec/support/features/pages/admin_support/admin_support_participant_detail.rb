# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class AdminSupportParticipantDetail < ::Pages::BasePage
    set_url "/admin/participants/{participant_id}"
    # this is a hack as the participants name is the page title
    set_primary_heading(/^.*$/)

    def has_validation_status?(validation_status)
      element_has_content? self, "Validation status #{validation_status}".strip
    end

    def has_full_name?(full_name)
      element_has_content? self, "Full name #{full_name} Change name".strip
    end

    def has_email_address?(email_address)
      element_has_content? self, "Email address #{email_address} Change email".strip
    end

    def has_school?(school_name)
      element_has_content? self, "School #{school_name}".strip
    end

    def has_lead_provider?(lead_provider_name)
      element_has_content? self, "Lead provider #{lead_provider_name}".strip
    end

    def has_school_transfer?(school_name)
      # School transfers
      # | School name | Induction Programme | Start Date | End Date |
      # | {school_name} | Full induction programme | 1 September 2021 | 4 September 2021 |
    end
  end
end
