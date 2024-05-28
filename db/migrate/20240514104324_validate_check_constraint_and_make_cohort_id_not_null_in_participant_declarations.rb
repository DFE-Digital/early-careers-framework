class ValidateCheckConstraintAndMakeCohortIdNotNullInParticipantDeclarations < ActiveRecord::Migration[7.1]
  def up
    validate_check_constraint :participant_declarations, name: "participant_declarations_cohort_id_null"
    change_column_null :participant_declarations, :cohort_id, false
    remove_check_constraint :participant_declarations, name: "participant_declarations_cohort_id_null"
  end

  def down
    add_check_constraint :participant_declarations, "cohort_id IS NOT NULL", name: "participant_declarations_cohort_id_null", validate: false
    change_column_null :participant_declarations, :cohort_id, true
  end
end
