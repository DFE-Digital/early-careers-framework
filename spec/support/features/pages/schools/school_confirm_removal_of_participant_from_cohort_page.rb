# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class SchoolConfirmRemovalOfParticipantFromCohortPage < ::Pages::BasePage
    set_url "/schools/{slug}/participants/{participant_id}/remove"
    set_primary_heading(/\AConfirm you want to remove (.*)\z/)
  end
end
