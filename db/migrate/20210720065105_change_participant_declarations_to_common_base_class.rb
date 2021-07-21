# frozen_string_literal: true

class ChangeParticipantDeclarationsToCommonBaseClass < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    safety_assured do
      change_table :participant_declarations, bulk: true do |t|
        t.string :course_identifier, null: true
        t.string :evidence_held, null: true
        t.string :type, default: "ParticipantDeclaration::ECF"
        t.references :cpd_lead_provider, null: true, type: :uuid, index: { algorithm: :concurrently }
      end
    end
  end
end
