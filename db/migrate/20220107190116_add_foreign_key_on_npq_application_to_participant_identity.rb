# frozen_string_literal: true

class AddForeignKeyOnNPQApplicationToParticipantIdentity < ActiveRecord::Migration[6.1]
  def up
    add_foreign_key :npq_applications, :participant_identities, null: false, validate: false
  end

  # for some reason rollback fails to revert a "change" unless split into up and down
  def down
    remove_foreign_key :npq_applications, :participant_identities
  end
end
