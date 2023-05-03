# frozen_string_literal: true

class Induction::RemoveParticipantFromSchool < BaseService
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
        remove_mentor_from_school_mentor_pool
      end
      notify_participant if notify?
    end
  end

private

  attr_reader :participant_profile, :school, :sit_name

  def initialize(participant_profile:, school: nil, sit_name: nil)
    @participant_profile = participant_profile
    @school = school || current_induction_record&.school || participant_profile.school
    @sit_name = sit_name
  end

  def mentoring_induction_records
    InductionRecord.for_school(school).current.where(mentor_profile: participant_profile)
  end

  def notify_participant
    ParticipantMailer.with(participant_profile:, sit_name:).participant_removed_by_sit.deliver_later
  end

  def notify?
    sit_name && request_for_details_sent?
  end

  def remove_mentorship_relations
    mentoring_induction_records.each do |induction_record|
      Induction::ChangeMentor.call(induction_record:)
    end
    participant_profile.mentee_profiles.update_all(mentor_profile_id: nil)
  end

  def remove_mentor_from_school_mentor_pool
    Mentors::RemoveFromSchool.call(mentor_profile: participant_profile, school:)
  end
end
