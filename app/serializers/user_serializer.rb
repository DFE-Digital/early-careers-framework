# frozen_string_literal: true

class UserSerializer
  include JSONAPI::Serializer

  set_id :id
  attributes :email, :full_name
end
