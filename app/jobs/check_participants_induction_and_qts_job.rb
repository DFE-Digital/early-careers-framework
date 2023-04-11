# frozen_string_literal: true

class CheckParticipantsInductionAndQtsJob < ApplicationJob
  def perform
    ects_with_no_induction.find_each do |participant_profile|
      validation_data = participant_profile.validation_data
      next if validation_data.nil?

      result = DqtRecordCheck.call(trn: validation_data.trn,
                                   nino: validation_data.nino,
                                   full_name: validation_data.full_name,
                                   date_of_birth: validation_data.date_of_birth)
      induction_start_date = result&.dqt_record&.induction_start_date
      next if induction_start_date.nil?

      participant_profile.update!(induction_start_date:)
      # Participants::ParticipantValidationForm.call(participant_profile)
    end

    ects_with_previous_induction_or_no_qts.find_each do |participant_profile|
      Participants::ParticipantValidationForm.call(participant_profile)
    end
  end

private

  def ects_with_previous_induction_or_no_qts
    ParticipantProfile::ECT.joins(:ecf_participant_eligibility)
                           .where(ecf_participant_eligibility: { reason: %w[no_qts previous_induction], manually_validated: false })
  end

  def ects_with_no_induction
    ParticipantProfile::ECT.joins(:ecf_participant_eligibility)
                           .where(ecf_participant_eligibility: { reason: %w[no_induction], manually_validated: false })
  end
end
