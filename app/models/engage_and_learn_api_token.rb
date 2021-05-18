# frozen_string_literal: true

class EngageAndLearnApiToken < ApplicationRecord
  def self.create_with_random_token!
    unhashed_token, hashed_token = Devise.token_generator.generate(EngageAndLearnApiToken, :hashed_token)
    create!(hashed_token: hashed_token)
    unhashed_token
  end

  def self.find_by_unhashed_token(unhashed_token)
    hashed_token = Devise.token_generator.digest(EngageAndLearnApiToken, :hashed_token, unhashed_token)
    find_by(hashed_token: hashed_token)
  end
end
