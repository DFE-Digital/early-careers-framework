# frozen_string_literal: true

class DeleteCompletedInductionRecordsJob < ApplicationJob
  def perform
    bug_introduced_at = "2023-09-04"
    job_running_window = { from: "00:00:00", to: "11:00:00" }

    records_deleted_count = 0
    records_failed_count = 0
    participants_fix_count = 0
    participants_failed_count = 0

    # Potential dup records created by the bug that was running from 4 Sept 2023, between midnight and 11am
    participant_profiles = ParticipantProfile
      .joins(induction_records: :versions)
      .where.not(induction_completion_date: nil)
      .where(induction_records: { induction_status: :changed, school_transfer: false })
      .where("induction_records.created_at >= ?", bug_introduced_at)
      .where("induction_records.created_at::time >= :from AND induction_records.created_at::time <= :to ", job_running_window)
      .where("versions.object_changes ->> 'induction_status' ILIKE '[%completed%changed%]'")
      .where("versions.whodunnit IS NULL")
      .distinct

    participant_profiles.in_batches(of: 500).each_record do |participant_profile|
      deleted, failed = Induction::DeleteDupRecords.new(participant_profile:).call
    rescue StandardError => e
      participants_failed_count += 1
      Rails.logger.debug "### Failed to fix participant #{participant_profile.id}: #{e.inspect}"
    else
      participants_fix_count += 1
      records_deleted_count += deleted
      records_failed_count += failed
    end

    Rails.logger.info "### Participants fixed: #{participants_fix_count}"
    Rails.logger.info "### Participants failed to fix: #{participants_failed_count}"

    Rails.logger.info "### Records deleted: #{records_deleted_count}"
    Rails.logger.info "### Records failed to delete: #{records_failed_count}"
  end
end
