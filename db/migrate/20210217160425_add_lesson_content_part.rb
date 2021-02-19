# frozen_string_literal: true

class AddLessonContentPart < ActiveRecord::Migration[6.1]
  def change
    create_table :course_lesson_parts do |t|
      t.timestamps

      t.column :title, :string, null: false
      t.column :content, :text, null: false, limit: 100_000

      t.references :previous_lesson_part, null: true, foreign_key: { to_table: :course_lesson_parts }, type: :uuid
      t.references :course_lesson, null: false, foreign_key: true, type: :uuid
    end
  end
end
