# frozen_string_literal: true

class LeadProviderProfile < ApplicationRecord
  has_paper_trail

  belongs_to :user
  belongs_to :lead_provider

  def self.create_lead_provider_user(full_name, email, lead_provider, start_url)
    ActiveRecord::Base.transaction do
      user = User.create!(full_name:, email:)
      LeadProviderProfile.create!(user:, lead_provider:)

      LeadProviderMailer.with(user:, lead_provider_name: lead_provider.name, start_url:).welcome_email.deliver_later
    end
  end
end
