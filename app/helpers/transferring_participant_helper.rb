# frozen_string_literal: true

module TransferringParticipantHelper
  def transfer_journey_previous_step(form)
    if form.same_programme
      email_schools_transferring_participant_path
    elsif form.schools_current_programme_choice.present?
      teachers_current_programme_schools_transferring_participant_path
    elsif form.teachers_current_programme_choice.present?
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
