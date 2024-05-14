# frozen_string_literal: true

class AddCheckConstraintForCohortIdNotNullInParticipantDeclarations < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :participant_declarations, "cohort_id IS NOT NULL", name: "participant_declarations_cohort_id_null", validate: false
  end
end

