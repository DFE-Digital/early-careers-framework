class AddEcfIds < ActiveRecord::Migration[6.1]
  def change
    add_column :applications, :ecf_id, :text, null: true
    add_column :courses, :ecf_id, :text, null: true
    add_column :lead_providers, :ecf_id, :text, null: true
  end
end
