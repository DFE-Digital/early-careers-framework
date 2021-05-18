class AddTokenInheritance < ActiveRecord::Migration[6.1]
  def change
    change_table :lead_provider_api_tokens, bulk: true do |t|
      t.change_null :lead_provider_id, true
      t.string :type, default: "LeadProviderApiToken"
    end

    rename_table :lead_provider_api_tokens, :api_tokens
  end
end
