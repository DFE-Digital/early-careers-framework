# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class UserSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      set_id :id
      attributes :email, :full_name, :get_an_identity_id
    end
  end
end
