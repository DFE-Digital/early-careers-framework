# frozen_string_literal: true

class MentorEctsForm
  include ActiveModel::Model

  attr_accessor :school_id, :user

  validates :mentor_id, presence: { message: I18n.t("errors.mentor.blank") }
  validates :user, presence: true
  validate :mentor_exists

  def available_ects
    @available_ects ||= Dashboard::Participants.new(school: @school, user:)
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
