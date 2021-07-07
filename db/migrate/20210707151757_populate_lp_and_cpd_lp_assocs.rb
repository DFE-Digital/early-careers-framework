# frozen_string_literal: true

class PopulateLpAndCpdLpAssocs < ActiveRecord::Migration[6.1]
  def up
    LeadProvider.all.each do |lp|
      lp.update(cpd_lead_provider: CpdLeadProvider.find_by(name: lp.name))
    end

    NpqLeadProvider.all.each do |lp|
      lp.update(cpd_lead_provider: CpdLeadProvider.find_by(name: lp.name))
    end
  end

  def down
    LeadProvider.update_all(cpd_lead_provider: nil)
    NpqLeadProvider.update_all(cpd_lead_provider: nil)
  end
end
