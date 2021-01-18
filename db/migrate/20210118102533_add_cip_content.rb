# frozen_string_literal: true

class AddCipContent < ActiveRecord::Migration[6.1]
  def change
    create_table :course_years, id: :uuid do |t|
      t.timestamps
      t.column :is_year_one, :boolean, null: false
      t.column :title, :string, null: false
      t.column :content, :string, null: false

      t.references :lead_provider, null: false, foreign_key: true, type: :uuid
    end

    create_table :course_modules, id: :uuid do |t|
      t.timestamps
      t.column :title, :string, null: false
      t.column :content, :string, null: false

      t.references :course_modules, null: true, foreign_key: { to_table: :course_modules }, type: :uuid
      t.references :previous_module, null: true, foreign_key: { to_table: :course_modules }, type: :uuid
      t.references :course_year, null: false, foreign_key: true, type: :uuid
    end

    create_table :course_lessons, id: :uuid do |t|
      t.timestamps
      t.column :title, :string, null: false
      t.column :content, :string, null: false

      t.references :next_lesson, null: true, foreign_key: { to_table: :course_lessons }, type: :uuid
      t.references :previous_lesson, null: true, foreign_key: { to_table: :course_lessons }, type: :uuid
      t.references :course_module, null: false, foreign_key: true, type: :uuid
    end
  end
end
