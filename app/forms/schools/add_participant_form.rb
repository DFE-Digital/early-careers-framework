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
    attribute :full_name
    attribute :email

    validates :type,
              on: :type,
              presence: { message: "Please select type of the new participant" },
              inclusion: { in: TYPE_OPTIONS.keys.map(&:to_s), allow_blank: true }

    validates :full_name,
              on: :details,
              presence: true

    validates :email,
              on: :details,
              presence: true,
              format: { with: Devise.email_regexp, allow_blank: true }

    def type_options
      TYPE_OPTIONS
    end
  end
end
