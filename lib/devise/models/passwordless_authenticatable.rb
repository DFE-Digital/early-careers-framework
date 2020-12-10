# frozen_string_literal: true

require Rails.root.join("lib/devise/strategies/passwordless_authenticatable")

module Devise
  module Models
    module PasswordlessAuthenticatable
      extend ActiveSupport::Concern
    end
  end
end
