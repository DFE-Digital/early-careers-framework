# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :lead_provider
end
