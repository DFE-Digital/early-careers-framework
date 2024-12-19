# frozen_string_literal: true

class AddMentorToParticipantDeclarationsAndStatementLineItems < ActiveRecord::Migration[7.1]
  def up
    add_column :participant_declarations, :mentor, :boolean, default: false, null: false
    add_column :statement_line_items, :mentor, :boolean, default: false, null: false

    ParticipantDeclaration::ECF.includes(:participant_profile, :statement_line_items).find_each do |declaration|
      mentor = declaration.participant_profile.mentor?
      declaration.update!(mentor:)
      declaration.statement_line_items.update_all(mentor:)
    end
  end

  def down
    remove_column :participant_declarations, :mentor
    remove_column :statement_line_items, :mentor
  end
end
