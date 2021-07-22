# frozen_string_literal: true

class ParticipantDeclaration::ECF < ParticipantDeclaration
  def valid_courses
    %w[ecf-induction ecf-mentor]
  end
end
