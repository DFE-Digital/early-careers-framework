# frozen_string_literal: true

class UpdateLeadershipLearningSouthEastLeadProviderNameToLlse < ActiveRecord::Migration[7.0]
  def up
    CpdLeadProvider.where(name: "Leadership Learning South East").update_all(name: "LLSE")
  end

  def down
    CpdLeadProvider.where(name: "LLSE").update_all(name: "Leadership Learning South East")
  end
end
