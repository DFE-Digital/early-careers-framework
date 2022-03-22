class CreateTableAuthTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :auth_tokens do |t|
      t.belongs_to :cpd_lead_provider
      t.string :accessor, index: true
      t.timestamps
    end
  end
end
