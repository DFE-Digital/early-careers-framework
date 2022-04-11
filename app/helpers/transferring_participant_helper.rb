# frozen_string_literal: true

module TransferringParticipantHelper
  def transfer_journey_previous_step(form)
    schools_choice = form.schools_current_programme_choice
    teachers_choice = form.teachers_current_programme_choice

    if schools_choice == "yes"
      schools_current_programme_schools_transferring_participant_path
    elsif teachers_choice == "yes"
      teachers_current_programme_schools_transferring_participant_path
    elsif schools_choice == "no" && teachers_choice == "no"
      schools_current_programme_schools_transferring_participant_path
    else
      dob_schools_transferring_participant_path
    end
  end

  def teachers_programme_path_previous_step(participant, school_cohort)
    if participant.ect? && school_cohort.active_mentors.any?
      choose_mentor_schools_transferring_participant_path
    else
      email_schools_transferring_participant_path
    end
  end
end
