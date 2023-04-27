# frozen_string_literal: true

class AmendUniqueIndexParticipantDeclaration < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    remove_index :participant_declarations, column: %i[cpd_lead_provider_id participant_profile_id declaration_type course_identifier state], if_exists: true

    add_index :participant_declarations, %i[cpd_lead_provider_id participant_profile_id declaration_type course_identifier state], unique: true, name: :unique_declaration_index, where: "state IN ('submitted', 'eligible', 'payable', 'paid')", algorithm: :concurrently
  end

  def down
    remove_index :participant_declarations, column: %i[cpd_lead_provider_id participant_profile_id declaration_type course_identifier state], name: :unique_declaration_index, if_exists: true

    add_index :participant_declarations, %i[cpd_lead_provider_id participant_profile_id declaration_type course_identifier state], unique: true, name: :unique_declaration_index, where: "state IN ('submitted', 'eligible', 'payable', 'paid', 'clawed_back')", algorithm: :concurrently
  end
end
