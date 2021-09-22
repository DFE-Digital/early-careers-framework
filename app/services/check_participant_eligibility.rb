# frozen_string_literal: true

class CheckParticipantEligibility < BaseService
  attr_reader :trn

  def initialize(trn:)
    @trn = trn
  end

  def call
    ineligible_record = ECFIneligibleParticipant.find_by(trn: trn)

    # logic is reversed in the data snapshot from TRA (:previous_induction)
    # so if your TRN is present, you're valid
    if ineligible_record.present?
      case ineligible_record.reason.to_sym
      when :previous_induction
        # this is reversed and indicates that the TRN is eligible
        nil
      when :previous_induction_and_participation
        :previous_participation
      when :previous_participation
        :previous_induction_and_participation
      end
    else
      :previous_induction
    end
  end
end
