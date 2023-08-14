# frozen_string_literal: true

class Participants::SetStartDateFromDQT < ::BaseService
  def call
    return unless participant_profile.ect?
    return if trn.blank?

    induction = DQT::GetInductionRecord.call(trn:)
    return if induction.blank?

    start_date = induction["startDate"]

    participant_profile.update!(induction_start_date: start_date)
  end

private

  attr_reader :participant_profile

  def initialize(participant_profile:)
    @participant_profile = participant_profile
  end

  def trn
    @trn ||= participant_profile&.teacher_profile&.trn
  end
end
