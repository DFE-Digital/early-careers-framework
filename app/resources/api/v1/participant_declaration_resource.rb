# frozen_string_literal: true

module Api
  module V1
    class ParticipantDeclarationResource < JSONAPI::Resource
      attribute :participant_id, delegate: :user_id
      attributes :declaration_date,
                 :declaration_type

      def raw_event

      end
    end
  end
end
