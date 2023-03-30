# frozen_string_literal: true

class ParticipantMentorForm
  include ActiveModel::Model

  attr_accessor :mentor_id, :school_id, :user_id, :cohort_id

  validates :mentor_id, presence: { message: I18n.t("errors.mentor.blank") }
  validate :mentor_exists

  def mentor
    @mentor ||= User.find(mentor_id) if mentor_id
  end

  def available_mentors
    school.mentors
  end

private

  def school
    @school ||= School.find(school_id)
  end

  def mentor_exists
    if mentor_id && mentor && available_mentors.exclude?(mentor)
      errors.add(:mentor_id, :not_authorized)
    end
  end
end
