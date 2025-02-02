# frozen_string_literal: true

require "jsonapi/serializer/instrumentation"

module Api
  module V3
    class ParticipantDeclarationSerializer
      include JSONAPI::Serializer
      include JSONAPI::Serializer::Instrumentation

      set_id :id
      set_type :'participant-declaration'

      attributes :participant_id, :declaration_type, :course_identifier

      attribute :declaration_date do |declaration|
        declaration.declaration_date.rfc3339
      end

      attribute(:mentor_id, &:mentor_user_id)
      attribute(:participant_id, &:user_id)

      attribute :state do |declaration|
        declaration.current_state.dasherize
      end

      attribute :updated_at do |declaration|
        declaration.updated_at.rfc3339
      end

      attribute :created_at do |declaration|
        declaration.created_at.rfc3339
      end

      attribute :delivery_partner_id do |declaration|
        if declaration.ecf?
          declaration.delivery_partner_id
        end
      end

      attribute :statement_id do |declaration|
        declaration.statement_line_items.detect(&:billable?)&.statement_id
      end

      attribute :clawback_statement_id do |declaration|
        declaration.statement_line_items.detect(&:refundable?)&.statement_id
      end

      attribute :ineligible_for_funding_reason do |declaration|
        if declaration.ineligible?
          reason = declaration.declaration_states.detect(&:ineligible?)&.state_reason

          case reason
          when "duplicate"
            "duplicate_declaration"
          else
            reason
          end
        end
      end

      attribute(:uplift_paid, &:uplift_paid?)

      attribute :evidence_held do |declaration|
        if declaration.ecf?
          declaration.evidence_held
        end
      end

      attribute :has_passed do |_declaration|
        nil
      end

      attribute :lead_provider_name do |declaration|
        declaration.cpd_lead_provider&.name
      end
    end
  end
end
