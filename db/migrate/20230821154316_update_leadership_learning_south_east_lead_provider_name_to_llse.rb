# frozen_string_literal: true

class UpdateLeadershipLearningSouthEastLeadProviderNameToLlse < ActiveRecord::Migration[7.0]
  def up
    NPQLeadProvider.where(name: "Leadership Learning South East").update_all(name: "LLSE") if defined?(NPQLeadProvider)
    CpdLeadProvider.where(name: "Leadership Learning South East").update_all(name: "LLSE")
  end

  def down
    NPQLeadProvider.where(name: "LLSE").update_all(name: "Leadership Learning South East") if defined?(NPQLeadProvider)
    CpdLeadProvider.where(name: "LLSE").update_all(name: "Leadership Learning South East")
  end
end
