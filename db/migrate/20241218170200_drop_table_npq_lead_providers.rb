# frozen_string_literal: true

class DropTableNPQLeadProviders < ActiveRecord::Migration[7.1]
  def up
    remove_foreign_key :npq_lead_providers, :cpd_lead_providers
    drop_table :npq_lead_providers
  end

  def down
    create_table :npq_lead_providers, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.text :name, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.uuid :cpd_lead_provider_id
      t.boolean :vat_chargeable, default: true

      t.index :cpd_lead_provider_id, name: "index_npq_lead_providers_on_cpd_lead_provider_id"
    end

    add_foreign_key :npq_lead_providers, :cpd_lead_providers
  end
end
