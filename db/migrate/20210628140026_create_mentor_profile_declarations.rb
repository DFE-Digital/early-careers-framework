class CreateMentorProfileDeclarations < ActiveRecord::Migration[6.1]
  def change
    create_table :mentor_profile_declarations do |t|
      t.references :profile_declarations, null: false, index: true
      t.references :mentor_profiles, null: false, index: true
      t.timestamps
    end
  end
end
