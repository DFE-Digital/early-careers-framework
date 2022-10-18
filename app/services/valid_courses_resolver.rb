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


def valid_courses
  case course_identifier
  when "ecf-induction"
    %w[ecf-induction]
  when "ecf-mentor"
    %w[ecf-mentor]
  else
    errors.add(:course_identifier, I18n.t(:invalid_identifier))
  end
end
