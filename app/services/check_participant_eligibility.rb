# frozen_string_literal: true

class CheckParticipantEligibility < BaseService
  attr_reader :trn

  def initialize(trn:)
    @trn = trn
  end

  def call
    ineligible_record = ECFIneligibleParticipant.find_by(trn: trn)
    return ineligible_record.reason.to_sym if ineligible_record.present?
  end
end
