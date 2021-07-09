# frozen_string_literal: true

module Api
  module V1
    class LeadProviderResource < JSONAPI::Resource
      has_many :participant_declarations
    end
  end
end
