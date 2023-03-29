# frozen_string_literal: true

module Admin::Participants
  class AddMentorToSchoolForm < Admin::BaseForm
    attr_accessor :mentor_profile, :school_urn

    validate :school_exists
    validate :mentoring_in_school
    validates :school_urn, presence: true

    def save
      return false if invalid?

      return true if Mentors::AddToSchool.call(mentor_profile:, school:)
    end

  private

    def school
      @school ||= School.find_by_urn(school_urn)
    end

    def school_exists
      errors.add(:school_urn, :school_missing) if school.nil?
    end

    def mentoring_in_school
      errors.add(:school_urn, :already_in_mentor_pool) if mentor_profile.school_mentors.where(school:).exists?
    end
  end
end
