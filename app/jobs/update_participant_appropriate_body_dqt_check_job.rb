# frozen_string_literal: true

class UpdateParticipantAppropriateBodyDQTCheckJob < ApplicationJob
  queue_as :default

  def perform(participant_profile_id)
    # Participant profiles sometimes are getting deleted (when dedupped for example).
    # Ensure they exist before updating the DQT AB check record.
    if ParticipantAppropriateBodyDQTCheck.exists?(participant_profile_id:)
      check_record = ParticipantAppropriateBodyDQTCheck.find_by(participant_profile_id:)

      # Get the appropriate body name from DQT's latest period
      dqt_response = DQT::V3::Client.new.get_record(trn: check_record.participant_profile.trn)
      dqt_latest_period = dqt_response["induction"]["periods"].max_by { |period| period["startDate"] }
      dqt_ab_name = dqt_latest_period["appropriateBody"]["name"]

      check_record.update!(dqt_appropriate_body_name: dqt_ab_name)
    else
      Rails.logger.info "Couldn't find the participant profile with id #{participant_profile_id}"
    end
  end
end
