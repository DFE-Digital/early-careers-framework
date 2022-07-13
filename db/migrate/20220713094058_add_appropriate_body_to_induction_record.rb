class AddAppropriateBodyToInductionRecord < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_reference :induction_records, :appropriate_body, null: true
    end
  end
end
