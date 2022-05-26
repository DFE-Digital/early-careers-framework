# frozen_string_literal: true

require_relative "./participant_registration_wizard"

module Pages
  class MentorRegistrationWizard < ::Pages::ParticipantRegistrationWizard
    set_url "/participants/validation/check-trn-given"
    set_primary_heading "Have you been given a teacher reference number (TRN)?"

    def complete(participant_name, participant_dob, trn)
      complete_for_mentor participant_name, participant_dob, trn
    end
  end
end
