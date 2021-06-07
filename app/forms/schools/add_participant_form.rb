# frozen_string_literal: true

module Schools
  class AddParticipantForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Serialization

    TYPE_OPTIONS = {
      ect: "Early Career Teacher",
      mentor: "Mentor",
    }.freeze

    attribute :type

    validates :type,
              on: :type,
              presence: { message: "Please select type of the new participant" },
              inclusion: { in: TYPE_OPTIONS.keys.map(&:to_s), allow_blank: true }

    def type_options
      TYPE_OPTIONS
    end
  end
end
