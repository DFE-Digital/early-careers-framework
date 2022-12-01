# frozen_string_literal: true

class RenameAppropriateBodyOnInductionRecords < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      rename_column :induction_records, :appropriate_body_id, :customized_appropriate_body_id

      InductionRecord.joins(induction_programme: :school_cohort)
                     .where("customized_appropriate_body_id = school_cohorts.appropriate_body_id")
                     .update_all(customized_appropriate_body_id: nil)
    end
  end
end
