# frozen_string_literal: true

class Induction::RemoveParticipant < BaseService
  delegate :mentor?, :request_for_details_sent?, :withdrawn_record!, to: :participant_profile

  def call
    ActiveRecord::Base.transaction do
      withdrawn_record!
      remove_mentorship_relations if mentor?
      notify_participant if request_for_details_sent?
    end
  end

private

  attr_reader :participant_profile, :sit_profile

  def initialize(participant_profile:, sit_profile:)
    @participant_profile = participant_profile
    @sit_profile = sit_profile
  end

  def notify_participant
    ParticipantMailer.participant_removed_by_sit(participant_profile:, sit_profile:).deliver_later
  end

  def remove_mentorship_relations
    InductionRecord.current.where(mentor_profile: participant_profile).each do |induction_record|
      Induction::ChangeMentor.call(induction_record:)
    end
    participant_profile.mentee_profiles.update_all(mentor_profile_id: nil)
  end
end
