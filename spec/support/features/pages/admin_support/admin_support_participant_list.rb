# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class AdminSupportParticipantList < ::Pages::BasePage
    set_url "/admin/participants"
    # this is a hack as the participants name is the page title
    set_primary_heading("Participants")

    element :search_field, "input#query-field"
    element :search_button, 'button[data-test="search-button"'

    sections :search_results, 'table[data-test="admin-participants-table"] > tbody > tr' do
      element :full_name, 'td[data-test="full-name"'
      element :role, 'td[data-test="role"'
      element :trn, 'td[data-test="trn"'
      element :school_name, 'td[data-test="school-name"'
      element :school_urn, 'td[data-test="school-urn"'
      element :date_added, 'td[data-test="date-added"'
      element :training_record_state, 'td[data-test="training-record-state"'
    end

    def view_participant(participant_name)
      click_on participant_name

      Pages::AdminSupportParticipantDetail.loaded
    end
  end
end
