# frozen_string_literal: true

class ProfileDeclarationToParticipantProfilesAssociation < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :profile_declarations, :declarable_type, :string }
    safety_assured { rename_column :profile_declarations, :declarable_id, :participant_profile_id }

    add_foreign_key :profile_declarations, :participant_profiles, validate: false
  end
end
