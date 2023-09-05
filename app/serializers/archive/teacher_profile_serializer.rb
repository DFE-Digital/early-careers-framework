# frozen_string_literal: true

module Archive
  class TeacherProfileSerializer
    include JSONAPI::Serializer

    set_id :id

    attribute :trn
    attribute :school_id
  end
end
