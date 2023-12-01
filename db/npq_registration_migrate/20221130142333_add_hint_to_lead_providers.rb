class AddHintToLeadProviders < ActiveRecord::Migration[6.1]
  def up
    add_column :lead_providers, :hint, :string

    school_led_network_lead_provider = LeadProvider.find_by(ecf_id: LeadProvider::ALL_PROVIDERS["School-Led Network"])

    school_led_network_lead_provider.update!(
      hint: "You can only register with this provider if you already started your NPQ with them in October 2022.",
    )
  end

  def down
    remove_column :lead_providers, :hint
  end
end
