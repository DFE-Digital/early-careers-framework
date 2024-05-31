# frozen_string_literal: true

require_relative "../base_page"

module Pages
  class AdminParticipantIdentityValidation < ::Pages::BasePage
    set_url "/admin/participants/{participant_id}/validations/identity"

    set_primary_heading("Identity confirmation")

    element :rejected, "label", text: "Rejected"
    element :approved, "label", text: "Approved"
    element :decision_notes, "textarea#profile-validation-decision-note-field"
    element :confirm_button, "button", text: "Confirm decision"
  end
end
