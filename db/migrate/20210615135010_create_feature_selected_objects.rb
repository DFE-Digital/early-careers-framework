# frozen_string_literal: true

class CreateFeatureSelectedObjects < ActiveRecord::Migration[6.1]
  def change
    create_table :feature_selected_objects do |t|
      t.references :object, null: false, polymorphic: true
      t.references :feature, null: false, foreign_key: true

      t.timestamps

      t.index %i[object_id feature_id object_type], unique: true, name: :unique_selected_object
    end
  end
end
