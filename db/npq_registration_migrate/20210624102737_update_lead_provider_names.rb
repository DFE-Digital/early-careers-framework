class UpdateLeadProviderNames < ActiveRecord::Migration[6.1]
  def change
    LeadProvider.where(name: "Best Practice Network").update_all(name: "Best Practice Network (home of Outstanding Leaders Partnership)")
    LeadProvider.where(name: "Leadership Learning South East").update_all(name: "Leadership Learning South East (LLSE)")
  end
end
