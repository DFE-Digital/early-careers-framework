# frozen_string_literal: true

class RemoveColumnDefaultFromSchoolCohorts < ActiveRecord::Migration[6.1]
  def change
    change_column_default :school_cohorts, :induction_programme_choice, from: "not_yet_known", to: nil
  end
end
