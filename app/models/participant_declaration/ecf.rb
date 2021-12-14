# frozen_string_literal: true

class ParticipantDeclaration::ECF < ParticipantDeclaration
  include RecordDeclarations::ECF

  def duplicate_declarations
    self.class.joins(participant_profile: :teacher_profile)
      .where(participant_profiles: { teacher_profiles: { trn: participant_profile.teacher_profile.trn } })
      .where.not(user_id: user_id)
      .where(
        declaration_type: declaration_type,
        course_identifier: course_identifier,
        declaration_date: declaration_date,
      )
  end
end
