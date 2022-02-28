# frozen_string_literal: true

class CheckNoInductionParticipantsJob < ApplicationJob
  def perform
    ECFParticipantEligibility.where(no_induction: true).find_each do |eligibility|
      revalidate(eligibility.participant_profile)
    end
  end

private

  def revalidate(participant_profile)
    validation_data = participant_profile.ecf_participant_validation_data

    validation_attributes =
      validation_data.attributes.symbolize_keys.slice(
        :trn, :nino, :full_name, :date_of_birth
      )

    dqt_response = ParticipantValidationService.validate(
      config: {
        check_first_name_only: true,
      },
      **validation_attributes,
    )

    validation_attributes[:dob] = validation_attributes.delete(:date_of_birth)

    StoreValidationResult.call(
      participant_profile: participant_profile,
      validation_data: validation_attributes,
      dqt_response: dqt_response,
    )
  end
end
