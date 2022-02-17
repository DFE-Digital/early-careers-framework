# frozen_string_literal: true

class Induction::Withdraw < BaseService
  def call
    induction_programme.active_induction_records.find_by(participant_profile: participant_profile)&.update!(status: state, end_date: end_date)
  end

private

  attr_reader :participant_profile, :induction_programme, :state, :end_date

  def initialize(participant_profile:, induction_programme:, state:, end_date:)
    @participant_profile = participant_profile
    @induction_programme = induction_programme
    @state = state
    @end_date = end_date
  end
end
