# frozen_string_literal: true

class MigrationLeadProvider2 < ApplicationRecord
  self.table_name = "lead_providers"
end

class MigrationNPQLeadProvider2 < ApplicationRecord
  self.table_name = "npq_lead_providers"
end

class MigrationCpdLeadProvider2 < ApplicationRecord
  self.table_name = "cpd_lead_providers"
end

class PopulateLpAndCpdLpAssocs < ActiveRecord::Migration[6.1]
  def up
    MigrationLeadProvider2.all.each do |lp|
      lp.update!(cpd_lead_provider_id: MigrationCpdLeadProvider2.find_by(name: lp.name)&.id)
    end

    MigrationNPQLeadProvider2.all.each do |lp|
      lp.update!(cpd_lead_provider_id: MigrationCpdLeadProvider2.find_by(name: lp.name)&.id)
    end
  end

  def down
    MigrationLeadProvider2.update_all(cpd_lead_provider: nil)
    MigrationNPQLeadProvider2.update_all(cpd_lead_provider: nil)
  end
end
