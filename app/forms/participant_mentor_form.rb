# frozen_string_literal: true

class ParticipantMentorForm
  include ActiveModel::Model

  attr_accessor :mentor_id, :school_id, :user

  validates :mentor_id, presence: { message: I18n.t("errors.mentor.blank") }
  validates :user, presence: true
  validate :mentor_exists

  def mentor
    @mentor ||= User.find(mentor_id) if mentor_id
  end

  def available_mentors
    @available_mentors ||= school.mentors - [user]
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
