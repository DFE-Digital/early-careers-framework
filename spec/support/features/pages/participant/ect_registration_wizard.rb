# frozen_string_literal: true

require_relative "./participant_registration_wizard"

module Pages
  class EctRegistrationWizard < ::Pages::ParticipantRegistrationWizard
    set_url "/participants/validation/trn"
    set_primary_heading "What’s your teacher reference number (TRN)?"

    def complete(participant_name, participant_dob, trn)
      complete_for_ect participant_name, participant_dob, trn
    end
  end
end
