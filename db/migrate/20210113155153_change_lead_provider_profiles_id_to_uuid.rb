# frozen_string_literal: true

# rubocop:disable all
class ChangeLeadProviderProfilesIdToUuid < ActiveRecord::Migration[6.1]
  def change
    remove_column :lead_provider_profiles, :id
    add_column :lead_provider_profiles, :id, :uuid, null: false, default: -> { "gen_random_uuid()" }
    execute "ALTER TABLE lead_provider_profiles ADD PRIMARY KEY (id);"
  end
end
# rubocop:enable all
