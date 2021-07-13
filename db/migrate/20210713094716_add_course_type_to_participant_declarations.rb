# frozen_string_literal: true

class AddCourseTypeToParticipantDeclarations < ActiveRecord::Migration[6.1]
  def change
    add_column :participant_declarations, :course_type, :string, null: false, default: "ecf-induction"
  end
end
