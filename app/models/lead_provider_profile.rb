# frozen_string_literal: true

class LeadProviderProfile < BaseProfile
  belongs_to :user
  belongs_to :lead_provider

  def self.create_lead_provider_user(full_name, email, lead_provider, start_url)
    ActiveRecord::Base.transaction do
      user = User.create!(full_name: full_name, email: email)
      LeadProviderProfile.create!(user: user, lead_provider: lead_provider)
      LeadProviderMailer.welcome_email(user: user, lead_provider_name: lead_provider.name, start_url: start_url).deliver_now
    end
  end
end
