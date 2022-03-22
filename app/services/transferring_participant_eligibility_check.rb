# frozen_string_literal: true

class MatchAndCheckTransferringParticipant < BaseService
  def call
    current_validation.presence && dqt_validation.presence
  end

private

  def initialize(full_name:, trn:, date_of_birth:)
    @full_name = full_name
    @trn = trn
    @dob = date_of_birth
  end

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
