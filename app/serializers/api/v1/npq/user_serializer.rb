# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    module NPQ
      class UserSerializer < Api::V1::UserSerializer
        attributes :get_an_identity_id
      end
    end
  end
end
