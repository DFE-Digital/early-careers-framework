# frozen_string_literal: true

class AddTempTypeToParticipantDeclarations < ActiveRecord::Migration[7.1]
  def up
    add_column :participant_declarations, :temp_type, :string

    declarations = ParticipantDeclaration::ECF.joins(:participant_profile)
    mentor_declarations = declarations.where(participant_profile: { type: "ParticipantProfile::Mentor"})
    ect_declarations = declarations.where(participant_profile: { type: "ParticipantProfile::ECT"})

    mentor_declarations.in_batches(of: 1_000) { |batch| batch.update_all(temp_type: "ParticipantDeclaration::Mentor") }
    ect_declarations.in_batches(of: 1_000) { |batch| batch.update_all(temp_type: "ParticipantDeclaration::ECT") }
  end

  def down
    remove_column :participant_declarations, :temp_type
  end
end
