# frozen_string_literal: true

class SupportForm
  include ActiveModel::Model

  attr_accessor :message, :participant_profile_id, :school_id, :current_user
  attr_reader :subject

  validates :message, presence: { message: "Please provide details of your request" }
  validate :validate_provided_ids

  def save
    SupportQuery.create!(
      message:,
      user: current_user,
      subject:,
      additional_information:,
    ).tap(&:enqueue_support_query_sync_job)
  end

  def participant_profile
    ParticipantProfile.find_by(id: participant_profile_id)
  end

  def school
    @school ||= if school_id.present?
                  School.find_by(id: school_id)
                else
                  participant_profile&.school
                end
  end

  def subject=(new_subject)
    @subject = if SupportQuery::VALID_SUBJECTS.include?(new_subject)
                 new_subject
               else
                 :unspecified
               end
  end

  def additional_information
    {
      school_id: school&.id,
      participant_profile_id: participant_profile&.id,
    }.reject { |_k, v| v.blank? }
  end

private

  def validate_provided_ids
    if participant_profile_id.present? && participant_profile.nil?
      errors.add(:participant_profile_id, "is invalid")
    end

    if school_id.present? && school.nil?
      errors.add(:school_id, "is invalid")
    end
  end
end
