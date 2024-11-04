# frozen_string_literal: true

class UpdateParticipantAppropriateBodyDQTCheckJob < ApplicationJob
  queue_as :default

  def perform(participant_profile_id)
    # Ensure the record exists before updating
    crosscheck_record = find_crosscheck_record(participant_profile_id)
    return if crosscheck_record.nil?

    dqt_response = fetch_dqt_response(crosscheck_record&.participant_profile&.trn)
    attributes_to_update = extract_dqt_attributes(dqt_response)

    crosscheck_record.update!(attributes_to_update) if attributes_to_update.present?
  end

private

  def find_crosscheck_record(participant_profile_id)
    ParticipantAppropriateBodyDQTCheck.includes(:participant_profile).find_by(participant_profile_id:)
  end

  def fetch_dqt_response(trn)
    DQT::V3::Client.new.get_record(trn:)
  end

  def extract_dqt_attributes(dqt_response)
    dqt_induction_status = dqt_response.dig("induction", "status")

    # We need to get the appropriate body name from the latest period
    dqt_latest_period = dqt_response.dig("induction", "periods")&.max_by { |period| period["startDate"] }
    dqt_appropriate_body_name = dqt_latest_period&.dig("appropriateBody", "name")

    { dqt_appropriate_body_name:, dqt_induction_status: }.compact
  end
end
