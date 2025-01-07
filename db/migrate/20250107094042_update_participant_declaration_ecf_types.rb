# frozen_string_literal: true

class UpdateParticipantDeclarationECFTypes < ActiveRecord::Migration[7.1]
  def up
    declarations = ParticipantDeclaration::ECF.joins(:participant_profile)
    mentor_declarations = declarations.where(participant_profile: { type: "ParticipantProfile::Mentor"})
    ect_declarations = declarations.where(participant_profile: { type: "ParticipantProfile::ECT"})

    mentor_declarations.in_batches(of: 1_000) { |batch| batch.update_all(type: "ParticipantDeclaration::Mentor") }
    ect_declarations.in_batches(of: 1_000) { |batch| batch.update_all(type: "ParticipantDeclaration::ECT") }
  end

  def down
    ParticipantDeclaration::ECF.in_batches(of: 1_000) { |batch| batch.update_all(type: "ParticipantDeclaration::ECF") }
  end
end
