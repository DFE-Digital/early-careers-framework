# frozen_string_literal: true

class Induction::Enrol < BaseService
  def call
    # TODO: The participant_profile could already have an induction record already in play
    # that we could update with an end_date / status
    participant_profile.induction_records.create!(induction_programme: induction_programme,
                                                  start_date: start_date,
                                                  status: :active,
                                                  schedule: participant_profile.schedule)
  end

private

  attr_reader :participant_profile, :induction_programme, :start_date

  def initialize(participant_profile:, induction_programme: nil, start_date: Time.zone.now)
    @participant_profile = participant_profile
    @induction_programme = induction_programme || default_induction_programme
    @start_date = start_date
  end

  def default_induction_programme
    participant_profile.school_cohort.default_induction_programme
  end
end
