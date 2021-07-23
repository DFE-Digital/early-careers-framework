# frozen_string_literal: true

class ParticipantDeclaration::NPQ < ParticipantDeclaration
  def valid_courses
    NPQCourse.all.map(&:identifier)
  end
end
