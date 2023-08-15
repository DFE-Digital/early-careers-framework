# frozen_string_literal: true

# This is a one off job to update all of the induction start dates from DQT for
# all of the 2021/2022 ECTs that do not currently have them.
# It runs in batches of 200 as we have a 300 lookup per minute limit on the API
# There are approx 57600 participants in this state currently
class SetParticipantStartDateJob < ApplicationJob
  def perform
    ParticipantProfile::ECT
      .joins(schedule: :cohort)
      .eligible_status
      .where(cohort: { start_year: [2021, 2022] })
      .where(induction_start_date: nil)
      .order(:created_at)
      .limit(200)
      .each do |participant_profile|
        ActiveRecord::Base.no_touching do
          Participants::SetStartDateFromDQT.call(participant_profile:)
        end
      end
  rescue StandardError => e
    Rails.logger.error("SetParticipantStartDateJob: #{e.message}")
  end
end
