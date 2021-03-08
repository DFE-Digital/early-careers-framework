# frozen_string_literal: true

class LeadProviderProfile < ApplicationRecord
  belongs_to :user
  belongs_to :lead_provider

  include Discard::Model
  default_scope -> { kept }
end
