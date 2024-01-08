# frozen_string_literal: true

class DeleteCompletedInductionRecordsJob < ApplicationJob
  def perform(no_of_participants: nil)
    bug_introduced_at = "2023-09-04"
    job_running_window = { from: "00:00:00", to: "11:00:00" }

    deleted_count = 0
    failed_count = 0

    participants = ParticipantProfile::ECT
      .where.not(induction_completion_date: nil)
      .where(id: InductionRecord
        .joins(:versions)
        .where(induction_status: :changed, school_transfer: false)
        .where("induction_records.created_at >= ?", bug_introduced_at)
        .where("induction_records.created_at::time >= :from AND induction_records.created_at::time <= :to ", job_running_window)
        .where("versions.object_changes ->> 'induction_status' ILIKE '[%completed%changed%]'")
        .where("versions.whodunnit IS NULL")
        .select(:participant_profile_id))
      .limit(no_of_participants)

    if participants.empty?
      Rails.logger.info "### No ECT participants found with dup completed induction records"
      return
    end

    participants.in_batches.each_record do |pp|
      # Potential dup records created by the bug that was running from 4 Sept 2023, between midnight and 11am
      pp.induction_records
        .joins(:versions)
        .where(induction_status: :changed, school_transfer: false)
        .where("induction_records.created_at >= ?", bug_introduced_at)
        .where("induction_records.created_at::time >= :from AND induction_records.created_at::time <= :to ", job_running_window)
        .where("versions.object_changes ->> 'induction_status' ILIKE '[%completed%changed%]'")
        .where("versions.whodunnit IS NULL").find_each do |induction_record|
          # Try to safely delete the record without breaking the induction records sequence
          Induction::DeleteDupRecord.new(induction_record:).call

          Rails.logger.info "### Removed #{induction_record.id} record from #{induction_record.participant_profile_id} participant"
          deleted_count += 1
      rescue StandardError => e
        Rails.logger.debug "### Failed to remove #{induction_record.id} record from #{induction_record.participant_profile_id} participant: #{e.inspect}"
        failed_count += 1
        end
    end

    Rails.logger.info "### Records deleted: #{deleted_count}"
    Rails.logger.info "### Records failed to delete: #{failed_count}"
  end
end
