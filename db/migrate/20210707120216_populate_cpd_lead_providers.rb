# frozen_string_literal: true

class MigrationLeadProvider < ApplicationRecord
  self.table_name = "lead_providers"
end

class MigrationNPQLeadProvider < ApplicationRecord
  self.table_name = "npq_lead_providers"
end

class MigrationCpdLeadProvider < ApplicationRecord
  self.table_name = "cpd_lead_providers"
end

class PopulateCpdLeadProviders < ActiveRecord::Migration[6.1]
  def up
    all_provider_names = (MigrationLeadProvider.pluck(:name) + MigrationNPQLeadProvider.pluck(:name)).uniq

    all_provider_names.each do |name|
      MigrationCpdLeadProvider.create!(name: name)
    end
  end

  def down
    ActiveRecord::Base.connection.execute("TRUNCATE cpd_lead_providers")
  end
end
