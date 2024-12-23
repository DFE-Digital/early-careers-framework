# frozen_string_literal: true

class DropTableNPQCourses < ActiveRecord::Migration[7.1]
  def up
    if foreign_key_exists?(:participant_profiles, :npq_courses)
      remove_foreign_key :participant_profiles, :npq_courses
    end

    drop_table :npq_courses
  end

  def down
    create_table :npq_courses, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.text :name, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.text :identifier
    end

    add_foreign_key :participant_profiles, :npq_courses
  end
end
