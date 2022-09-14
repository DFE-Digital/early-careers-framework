# frozen_string_literal: true

class AddUniqueIndexParticipantDeclaration < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :participant_declarations, %i[cpd_lead_provider_id participant_profile_id declaration_type course_identifier state], unique: true, name: :unique_declaration_index, algorithm: :concurrently, where: "state IN ('submitted', 'eligible', 'payable', 'paid', 'clawed_back')"
  end
end
