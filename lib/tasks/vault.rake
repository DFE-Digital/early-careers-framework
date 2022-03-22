namespace :vault do
  desc "populate lead provider token"
  task lead_provider: :environment do
    pp Vault.address
    LeadProviderApiToken.joins(:cpd_lead_provider).where.not(cpd_lead_provider: nil).find_each do |lead_provider_api_token|
      lp = lead_provider_api_token.cpd_lead_provider
      pp lead_provider_api_token.hashed_token
      Vault.logical.write("cpdlp/#{lp.id}", token: lead_provider_api_token.hashed_token)
    end
  end

  task read_lead_provider: :environment do
    pp Vault.address
    LeadProviderApiToken.joins(:cpd_lead_provider).where.not(cpd_lead_provider: nil).find_each do |lead_provider_api_token|
      lp = lead_provider_api_token.cpd_lead_provider
      puts "#{lp.name} token: #{Vault.logical.read("cpdlp/#{lp.id}").data[:token]}"

    end
  end

end
