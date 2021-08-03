# frozen_string_literal: true

class ParticipantDeclaration::ECF < ParticipantDeclaration
  def valid_courses
    valid_courses = []
    valid_courses << "ecf-induction" if user&.early_career_teacher?
    valid_courses << "ecf-mentor" if user&.mentor?

    valid_courses
  end
end
