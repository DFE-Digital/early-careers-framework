# frozen_string_literal: true

require_relative "./participant_registration_wizard"

module Pages
  class MentorRegistrationWizard < ::Pages::ParticipantRegistrationWizard
    set_url "/participants/validation/check-trn-given"
    set_primary_heading "Have you been given a teacher reference number (TRN)?"

    def complete(participant_name, participant_dob, trn)
      setup_response_from_dqt participant_name, participant_dob, trn

      confirm_have_trn
      add_teacher_reference_number trn
      add_date_of_birth participant_dob
    end
  end
end
