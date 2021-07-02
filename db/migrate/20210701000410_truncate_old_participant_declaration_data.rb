# frozen_string_literal: true

class TruncateOldParticipantDeclarationData < ActiveRecord::Migration[6.1]
  def up
    ParticipantDeclaration.delete_all
  end

  def down
    ParticipantDeclaration.delete_all
    ProfileDeclaration.delete_all
  end
end
