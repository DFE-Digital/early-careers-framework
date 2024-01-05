# frozen_string_literal: true

class Induction::DeleteDupRecords < BaseService
  BUG_INTRODUCED_AT = "2023-09-04"
  JOB_RUNNING_WINDOW = 0..11
  COMPARE_ATTRIBUTES = %w[induction_programme_id participant_profile_id schedule_id training_status preferred_identity_id school_transfer appropriate_body_id].freeze

  attr_reader :deleted_count, :failed_count

  def call
    ActiveRecord::Base.transaction do
      induction_records[1..-2].each do |induction_record|
        reason = non_deletable?(induction_record)
        if reason
          Rails.logger.debug "### Failed to remove #{induction_record.id} record from #{induction_record.participant_profile_id} participant: #{reason}"
          @failed_count += 1

          next
        end
        update_previous_record(induction_record)

        destroy(induction_record)
      end
    end

    [deleted_count, failed_count]
  end

private

  attr_reader :participant_profile

  def initialize(participant_profile:)
    @participant_profile = participant_profile
    @deleted_count = 0
    @failed_count = 0
  end

  def destroy(induction_record)
    induction_record.destroy!
    Rails.logger.info "### Removed #{induction_record.id} record from #{induction_record.participant_profile_id} participant"
    @deleted_count += 1
  end

  def first_record?(induction_record)
    induction_records.first == induction_record
  end

  def induction_records
    @induction_records ||= participant_profile
                             .induction_records
                             .sort_by { |ir| [ir.start_date, ir.created_at] }
                             .reverse
  end

  def induction_record_index(induction_record)
    induction_records.index(induction_record)
  end

  def last_record?(induction_record)
    induction_records.last == induction_record
  end

  def next_record(induction_record)
    induction_records[induction_record_index(induction_record) - 1] unless first_record?(induction_record)
  end

  def non_deletable?(induction_record)
    return "Not 'Changed' induction status" unless induction_record.changed_induction_status?
    return "School transfer" if induction_record.school_transfer?
    return "Mentored" if induction_record.mentor_profile_id
    return "Prior to bug" if induction_record.created_at < BUG_INTRODUCED_AT
    return "Created out of bug run window" unless JOB_RUNNING_WINDOW === induction_record.created_at.hour
    return "Not created by bug" if induction_record.versions.none? { |v| v.whodunnit.nil? && v.object_changes["induction_status"] == %w[completed changed] }
    return "Record changed" if record_changed?(induction_record)
  end

  def previous_record(induction_record)
    induction_records[induction_record_index(induction_record) + 1] unless last_record?(induction_record)
  end

  def record_changed?(induction_record)
    induction_record.attributes.slice(*COMPARE_ATTRIBUTES) != previous_record(induction_record).attributes.slice(*COMPARE_ATTRIBUTES)
  end

  def update_previous_record(induction_record)
    previous_record(induction_record).update!(end_date: induction_record.end_date)
  end
end
