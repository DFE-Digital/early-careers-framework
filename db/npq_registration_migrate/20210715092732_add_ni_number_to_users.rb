class AddNiNumberToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :national_insurance_number, :text, null: true
  end
end
