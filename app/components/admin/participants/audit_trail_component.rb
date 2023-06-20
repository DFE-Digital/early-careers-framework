# frozen_string_literal: true

# copied from https://github.com/DFE-Digital/apply-for-teacher-training/blob/54899ba5ddd67958a09c9b2c2ec5818ad675dd6c/app/components/support_interface/audit_trail_component.rb

module Admin
  module Participants
    class AuditTrailComponent < ViewComponent::Base
      renders_many :audit_table_rows, "Admin::Participants::AuditTrailItemComponent"

      Changes = Struct.new(
        :id,
        :action,
        :created_at,
        :type,
        :user,
        :user_type,
        :audited_changes,
        keyword_init: true,
      )

      def initialize(audited_thing:)
        audits(audited_thing).each { |audit| with_audit_table_row(audit:) }
      end

    private

      def audits(audited_thing)
        audited_thing
          .group_by { |event| { id: event.id, action: event.action, date: event.date, type: event.type, user: event.user } }
          .map do |event, changes|
            audited_changes = changes.map { |change| { attribute: change.predicate, values: change.value } }

            Changes.new(
              id: event[:id],
              action: event[:action],
              created_at: event[:date],
              type: event[:type],
              user: event[:user],
              user_type: nil,
              audited_changes:,
            )
          end
      end
    end
  end
end
