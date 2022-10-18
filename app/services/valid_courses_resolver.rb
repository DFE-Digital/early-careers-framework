# frozen_string_literal: true

class ValidCoursesResolver
  class << self
    def call(course_identifier:)
      return unless course_identifier

      if course_identifier == "ecf-induction"
        %w[ecf-induction]
      elsif course_identifier == "ecf-mentor"
        %w[ecf-mentor]
      elsif ParticipantProfile::NPQ::COURSE_IDENTIFIERS.include?(course_identifier)
        NPQCourse.identifiers
      end
    end
  end
end

class CourseValidator < ActiveModel::Validator
  def validate(record)
    return if has_profile_for_course_given_course_identitfier?(record)

    record.errors.add(:course_identifier, I18n.t(:invalid_course))
  end

private

  def has_profile_for_course_given_course_identitfier?(record)
    return unless record.participant_identity&.user

    record.participant_identity.user.participant_profiles.active_record.any? do |participant_profile|
      participant_profile.class::COURSE_IDENTIFIERS.include?(record.course_identifier)
    end
  end
end
