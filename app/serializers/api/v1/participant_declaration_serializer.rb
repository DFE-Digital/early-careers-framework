# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V1
    class ParticipantDeclarationSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      # TODO: eligible_for_payment is deprecated, will need removing in one of next api versions
      # TODO: voided is deprecated, will need removing in one of next api versions

      set_id :id
      set_type :'participant-declaration'
      attributes :participant_id, :declaration_type, :course_identifier

      attribute :eligible_for_payment do |declaration|
        declaration.payable? || declaration.eligible?
      end

      attribute :declaration_date do |declaration|
        declaration.declaration_date.rfc3339
      end

      attribute :updated_at do |declaration|
        declaration.updated_at.rfc3339
      end

      attribute :voided, &:voided?

      attribute(:participant_id, &:user_id)

      attribute :state do |declaration|
        declaration.current_state.dasherize
      end

      attribute :has_passed, if: -> { FeatureFlag.active?(:participant_outcomes_feature) } do |declaration|
        if declaration.npq?
          declaration.outcomes.latest&.has_passed?
        end
      end
    end
  end
end
