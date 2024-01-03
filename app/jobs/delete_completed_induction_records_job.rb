# frozen_string_literal: true

class DeleteCompletedInductionRecordsJob < ApplicationJob
  def perform
    bug_introduced_at = "2023-09-04"
    job_running_window = { from: "00:00:00", to: "11:00:00" }

    deleted = []
    failed = []

    # Potential dup records created by the bug that was running from 4 Sept 2023, between midnight and 11am
    dup_induction_records = InductionRecord
      .joins(:participant_profile)
      .joins(:versions)
      .where.not(participant_profile: { induction_completion_date: nil })
      .where(induction_status: :changed, school_transfer: false)
      .where("induction_records.created_at >= ?", bug_introduced_at)
      .where("induction_records.created_at::time >= :from AND induction_records.created_at::time <= :to ", job_running_window)
      .where("versions.object_changes ->> 'induction_status' ILIKE '[%completed%changed%]'")
      .where("versions.whodunnit IS NULL")

    dup_induction_records.in_batches(of: 500).each_record do |induction_record|
      # Try to safely delete the record without breaking the induction records sequence
      Induction::DeleteDupRecord.new(induction_record:).call

      Rails.logger.info "### Removed #{induction_record.id} record from #{induction_record.participant_profile_id} participant"
      deleted << induction_record.id
    rescue StandardError
      Rails.logger.debug "### Failed to remove #{induction_record.id} record from #{induction_record.participant_profile_id} participant: #{e.inspect}"
      failed << induction_record.id
    end

    Rails.logger.info "### Records deleted: #{deleted.count}"
    Rails.logger.info "### Records failed to delete: #{failed.count}"
  end
end
