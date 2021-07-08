# frozen_string_literal: true

class PopulateCpdLeadProviders < ActiveRecord::Migration[6.1]
  def up
    all_provider_names = (LeadProvider.pluck(:name) + NpqLeadProvider.pluck(:name)).uniq

    all_provider_names.each do |name|
      CpdLeadProvider.create!(name: name)
    end
  end

  def down
    ActiveRecord::Base.connection.execute("TRUNCATE cpd_lead_providers")
  end
end
