# frozen_string_literal: true

class AddPrimaryKeyToCohortsLeadProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :cohorts_lead_providers, :id, :primary_key
  end
end
