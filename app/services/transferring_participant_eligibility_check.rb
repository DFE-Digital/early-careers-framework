# frozen_string_literal: true

class TransferringParticipantEligibilityCheck
  def call
    current_validation.presence && dqt_validation.presence
  end

  def initialize(transferring_form)
    @full_name = transferring_form.full_name
    @trn = transferring_form.trn
    @dob = transferring_form.date_of_birth
  end

private

  def current_validation
    ECFParticipantValidationData.find_by("LOWER(full_name) = ? AND trn = ? AND date_of_birth = ?", full_name.downcase, trn, dob)
  end

  def dqt_validation
    ParticipantValidationService.validate(
      full_name: full_name,
      trn: trn,
      date_of_birth: dob,
      nino: nil,
      config: {
        check_first_name_only: true,
      },
    )
  end

  attr_accessor :full_name, :trn, :dob
end
