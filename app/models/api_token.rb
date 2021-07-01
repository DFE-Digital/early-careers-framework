# frozen_string_literal: true

class ApiToken < ApplicationRecord
  # This is meant to be an abstract class
  # Since it is a base class for a STI, we can't actually make it abstract (not backed by a table)

  def self.create_with_random_token!(**options)
    unhashed_token, hashed_token = Devise.token_generator.generate(ApiToken, :hashed_token)
    create!(hashed_token: hashed_token, **options)
    unhashed_token
  end

  def self.find_by_unhashed_token(unhashed_token)
    hashed_token = Devise.token_generator.digest(ApiToken, :hashed_token, unhashed_token)
    find_by(hashed_token: hashed_token)
  end

  def self.create_with_known_token!(token, **options)
    hashed_token = Devise.token_generator.digest(ApiToken, :hashed_token, token)
    find_or_create_by!(hashed_token: hashed_token, **options)
  end

  def owner
    raise NotImplementedError
  end
end
