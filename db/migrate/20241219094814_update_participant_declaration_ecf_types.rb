# frozen_string_literal: true

class UpdateParticipantDeclarationECFTypes < ActiveRecord::Migration[7.1]
  def up
    ParticipantDeclaration::ECF.includes(:participant_profile).find_each do |declaration|
      type = mentor_declaration?(declaration) ? "ParticipantDeclaration::Mentor" : "ParticipantDeclaration::ECT"
      declaration.update!(type:)
    end
  end

  def down
    ParticipantDeclaration::ECF.update_all(type: "ParticipantDeclaration::ECF")
  end

  private

  def mentor_declaration?(declaration)
    declaration.participant_profile.mentor?
  end
end
