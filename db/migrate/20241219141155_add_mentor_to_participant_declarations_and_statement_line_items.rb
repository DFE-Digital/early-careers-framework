# frozen_string_literal: true

class AddMentorToParticipantDeclarationsAndStatementLineItems < ActiveRecord::Migration[7.1]
  def up
    add_column :participant_declarations, :mentor, :boolean, default: false, null: false
    add_column :statement_line_items, :mentor, :boolean, default: false, null: false

    mentor_declarations = ParticipantDeclaration::ECF
      .includes(:participant_profile, :statement_line_items)
      .where(participant_profiles: { type: "ParticipantProfile::Mentor" })

    mentor_declarations.update_all(mentor: true)

    mentor_statement_line_items = Finance::StatementLineItem.where(participant_declaration_id: mentor_declarations.pluck(:id))
    
    mentor_statement_line_items.update_all(mentor: true)
  end

  def down
    remove_column :participant_declarations, :mentor
    remove_column :statement_line_items, :mentor
  end
end
