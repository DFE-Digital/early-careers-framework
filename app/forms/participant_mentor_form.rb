# frozen_string_literal: true

class ParticipantMentorForm
  include ActiveModel::Model

  attr_accessor :mentor_id, :school_id, :user_id

  validate :mentor_exists

  def mentor
    mentor_id == "later" ? nil : User.find(mentor_id)
  end

  def available_mentors
    school.mentors.order(:full_name)
  end

private

  def school
    @school ||= School.find(school_id)
  end

  def mentor_exists
    if mentor && available_mentors.exclude?(mentor)
      errors.add(:mentor_id, :not_authorized)
    end
  end
end
