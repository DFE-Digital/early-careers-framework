# frozen_string_literal: true

class DeleteNPQDeclarations < ActiveRecord::Migration[7.1]
  def up
    npq_type = "ParticipantDeclaration::NPQ"

    DeclarationState.includes(:participant_declaration).where(participant_declaration: { type: npq_type } ).delete_all
    ParticipantDeclarationAttempt.includes(:participant_declaration).where(participant_declaration: { type: npq_type } ).delete_all
    ParticipantDeclaration.where(type: npq_type).delete_all
  end
end
