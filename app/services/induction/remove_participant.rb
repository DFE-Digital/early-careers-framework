# frozen_string_literal: true

class Induction::RemoveParticipant < BaseService
  delegate :current_induction_record,  to: :participant_profile
  delegate :mentor?,                   to: :participant_profile
  delegate :request_for_details_sent?, to: :participant_profile
  delegate :withdrawn_record!,         to: :participant_profile

  def call
    ActiveRecord::Base.transaction do
      withdrawn_record!
      current_induction_record&.withdrawing!
      if mentor?
        remove_mentorship_relations
        remove_mentor_from_school_mentor_list
      end
      notify_participant if notify?
    end
  end

private

  attr_reader :participant_profile, :sit_profile

  def initialize(participant_profile:, sit_profile: nil)
    @participant_profile = participant_profile
    @sit_profile = sit_profile
  end

  def mentoring_induction_records
    InductionRecord.current.where(mentor_profile: participant_profile)
  end

  def notify_participant
    ParticipantMailer.participant_removed_by_sit(participant_profile:, sit_profile:).deliver_later
  end

  def notify?
    sit_profile && request_for_details_sent?
  end

  def remove_mentorship_relations
    mentoring_induction_records.each do |induction_record|
      Induction::ChangeMentor.call(induction_record:)
    end
    participant_profile.mentee_profiles.update_all(mentor_profile_id: nil)
  end

  def remove_mentor_from_school_mentor_list
    Mentors::RemoveFromSchool.call(mentor_profile: participant_profile)
  end
end
