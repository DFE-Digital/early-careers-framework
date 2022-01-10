# frozen_string_literal: true

class RemoveUserReferenceFromNPQApplications < ActiveRecord::Migration[6.1]
  def up
    safety_assured { remove_reference :npq_applications, :user, null: true, foreign_key: true, type: :uuid }
  end

  def down
    add_reference :npq_applications, :user, null: true
    execute <<~SQL
      UPDATE npq_applications
      SET user_id = (
        SELECT user_id
        FROM participant_identities
        WHERE participant_identities.id = npq_applications.participant_identity_id
      );
    SQL
    add_foreign_key :npq_applications, :users, null: false, validate: false
  end
end
