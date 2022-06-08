# frozen_string_literal: true

class CheckParticipantPreviousParticipation < BaseService
  attr_reader :trn

  def initialize(trn:)
    @trn = trn
  end

  def call
    ineligible_record = ECFIneligibleParticipant.find_by(trn:)

    %i[previous_participation previous_induction_and_participation].include? ineligible_record&.reason&.to_sym
  end
end
