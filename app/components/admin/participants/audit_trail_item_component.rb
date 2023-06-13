# frozen_string_literal: true

# copied from https://github.com/DFE-Digital/apply-for-teacher-training/blob/54899ba5ddd67958a09c9b2c2ec5818ad675dd6c/app/components/support_interface/audit_trail_item_component.rb

module Admin
  module Participants
    class AuditTrailItemComponent < ViewComponent::Base
      include AdminHelper

      def initialize(audit:)
        @audit = audit
      end

      def audit_entry_event_label
        type = admin_participant_role_name(audit.type.to_s)
        type = audit.type.to_s.titlecase if type == "unknown"

        "#{audit.action.capitalize} #{type} ##{audit.id}"
      end

      def audit_entry_user_label
        user = audit.user

        return "(Unknown User)" if user.nil?
        return user if user.is_a?(String)

        if user.induction_coordinator?
          "#{user.email} (SIT user)"
        elsif audit.admin?
          "#{user.email} (Support user)"
        elsif audit.finance?
          "#{user.email} (Finance user)"
        elsif audit.delivery_partner?
          "#{user.email} (DP user)"
        elsif audit.appropriate_body?
          "#{user.email} (AB user)"
        elsif audit.lead_provider?
          "#{user.supplier_name} (LP user)"
        else
          audit.user.email
        end
      end

      def changes
        interesting_changes = audit.audited_changes.reject { |change| change[:attribute] == "id" }.compact_blank

        interesting_changes.sort_by { |change| change[:date] }.reverse!.map do |change|
          AuditTrailChange.new(attribute: change[:attribute], values: change[:values])
        end
      end

      def comment_change
        { "comment" => audit.comment }
      end

      attr_reader :audit

      class AuditTrailChange
        REDACTED_ATTRIBUTES = %w[sex disabilities ethnic_group ethnic_background hesa_sex hesa_disabilities hesa_ethnicity].freeze

        attr_reader :values, :attribute

        def initialize(attribute:, values:)
          @attribute = attribute
          @values = values
        end

        def formatted_values
          return "[REDACTED]" if REDACTED_ATTRIBUTES.include?(@attribute)
          return values.map { |v| redact_hash_data(v) || "nil" }.join(" → ") if values.is_a?(Array)

          (redact_hash_data(values) || "nil").to_s
        end

      private

        def redact_hash_data(value)
          return value unless value.is_a? Hash

          REDACTED_ATTRIBUTES.each do |field|
            next unless value[field]

            value[field] = "[REDACTED]"
          end

          value
        end
      end
    end
  end
end
