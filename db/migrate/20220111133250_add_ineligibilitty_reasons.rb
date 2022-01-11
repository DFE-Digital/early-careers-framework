class AddIneligibilittyReasons < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      change_table :participant_declarations, bulk: true do |t|
        t.enum :ineligibility_reason, as: "ineligibility_reason_type"
      end
    end
  end
end
