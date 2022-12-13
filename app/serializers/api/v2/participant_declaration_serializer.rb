# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V2
    class ParticipantDeclarationSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      set_id :id
      set_type :'participant-declaration'
      attributes :participant_id, :declaration_type, :course_identifier

      attribute :declaration_date do |declaration|
        declaration.declaration_date.rfc3339
      end

      attribute :updated_at do |declaration|
        declaration.updated_at.rfc3339
      end

      attribute(:participant_id, &:user_id)

      attribute :state do |declaration|
        declaration.current_state.dasherize
      end

      attribute :has_passed do |declaration|
        if declaration.npq?
          declaration.outcomes.latest&.passed?
        end
      end
    end
  end
end
