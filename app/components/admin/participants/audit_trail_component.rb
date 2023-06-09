# frozen_string_literal: true

# copied from https://github.com/DFE-Digital/apply-for-teacher-training/blob/54899ba5ddd67958a09c9b2c2ec5818ad675dd6c/app/components/support_interface/audit_trail_component.rb

module Admin
  module Participants
    class AuditTrailComponent < ViewComponent::Base
      def initialize(audited_thing:)
        @audited_thing = audited_thing
      end

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

      def audits
        audits = audited_thing.group_by do |event|
          {
            id: event.id,
            action: event.action,
            date: event.date,
            type: event.type,
            user: event.user,
          }
        end

        audits.map do |event, changes|
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

      attr_reader :audited_thing
    end
  end
end
