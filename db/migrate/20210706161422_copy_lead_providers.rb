# frozen_string_literal: true

class CopyLeadProviders < ActiveRecord::Migration[6.1]
  def up
    LeadProvider.all.each do |lp|
      EcfLeadProvider.create!(lp.attributes)
    end
  end

  def down
    ActiveRecord::Base.connection.execute("TRUNCATE ecf_lead_providers")
  end
end
