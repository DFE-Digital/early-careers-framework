# frozen_string_literal: true

class LeadProviderApiToken < ApplicationRecord
  belongs_to :lead_provider

  def self.create_with_random_token!(lead_provider:)
    unhashed_token, hashed_token = Devise.token_generator.generate(LeadProviderApiToken, :hashed_token)
    create!(hashed_token: hashed_token, lead_provider: lead_provider)
    unhashed_token
  end

  def self.find_by_unhashed_token(unhashed_token)
    hashed_token = Devise.token_generator.digest(LeadProviderApiToken, :hashed_token, unhashed_token)
    find_by(hashed_token: hashed_token)
  end
end
