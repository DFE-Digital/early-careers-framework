# frozen_string_literal: true

# copied from https://github.com/DFE-Digital/apply-for-teacher-training/blob/54899ba5ddd67958a09c9b2c2ec5818ad675dd6c/app/components/support_interface/audit_trail_item_component.rb

module Admin
  module Participants
    class AuditTrailItemComponent < ViewComponent::Base
      def initialize(audit:)
        @audit = audit
      end

      def audit_entry_event_label
        "#{audit.action.capitalize} #{audit.type.to_s.titlecase} ##{audit.id}"
      end

      def audit_entry_user_label
        if audit.user_type == "ApiUser"
          "#{audit.user.email_address} (Vendor API)"
        elsif audit.user_type == "SupportUser"
          "#{audit.user.email_address} (Support user)"
        elsif audit.user_type == "LeadProviderUser"
          "#{audit.user.email_address} (Provider user)"
        elsif audit.user_type == "SchoolUser"
          "#{audit.user.email_address} (School user)"
        elsif audit.username.present?
          audit.username
        else
          "(Unknown User)"
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
