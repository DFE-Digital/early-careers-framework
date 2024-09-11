# frozen_string_literal: true

module Oneoffs::NPQ
  class BulkChangeApplicationsToPending
    attr_reader :npq_application_ids

    def initialize(npq_application_ids:)
      @npq_application_ids = npq_application_ids
    end

    def run!(dry_run: true)
      result = {}

      ActiveRecord::Base.transaction do
        result = npq_application_ids.each_with_object({}) do |npq_application_id, hash|
          npq_application = NPQApplication.find_by(id: npq_application_id)
          success = npq_application && NPQ::ChangeToPending.call(npq_application:)
          hash[npq_application_id] = outcome(success, npq_application)
        end

        raise ActiveRecord::Rollback if dry_run
      end

      result
    end

  private

    def outcome(success, npq_application)
      return "Not found" if npq_application.nil?
      return "Already pending" if success && !npq_application.saved_change_to_lead_provider_approval_status?
      return "Changed to pending" if success

      npq_application.errors.map(&:type).join(", ")
    end
  end
end
