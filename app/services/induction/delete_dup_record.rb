# frozen_string_literal: true

class Induction::DeleteDupRecord < BaseService
  COMPARE_ATTRIBUTES = %(induction_programme_id participant_profile_id schedule_id training_status preferred_identity_id school_transfer appropriate_body_id)

  class DeleteInductionRecordRestrictionError < StandardError; end

  def call
    ActiveRecord::Base.transaction do
      check_record_is_deletable!

      update_previous_record
      delete_induction_record
    end
  end

private

  attr_reader :induction_record

  def initialize(induction_record:)
    @induction_record = induction_record
  end

  def check_record_is_deletable!
    raise DeleteInductionRecordRestrictionError, "Cannot delete record because it is active" if active?
    raise DeleteInductionRecordRestrictionError, "Cannot delete record because it is not in the middle of the induction records history" unless middle_of_history?
    raise DeleteInductionRecordRestrictionError, "Cannot delete record because it has been diverted from the previous record" if record_changed?
    raise DeleteInductionRecordRestrictionError, "Cannot delete record because the mentor does not matches the previous record" unless valid_mentor_value?
  end

  def active?
    induction_record.active?
  end

  def middle_of_history?
    previous_record && next_record
  end

  def record_changed?
    induction_record.attributes.slice(*COMPARE_ATTRIBUTES) != previous_record.attributes.slice(*COMPARE_ATTRIBUTES)
  end

  def valid_mentor_value?
    induction_record.mentor_profile_id.nil?
  end

  def delete_induction_record
    induction_record.destroy
  end

  def update_previous_record
    previous_record.update!(end_date: next_record.start_date)
  end

  def previous_record
    participant_induction_records[induction_record_index + 1] unless last_record?
  end

  def next_record
    participant_induction_records[induction_record_index - 1] unless first_record?
  end

  def participant_induction_records
    @participant_induction_records ||= induction_record
      .participant_profile
      .induction_records
      .order(start_date: :desc, created_at: :desc)
  end

  def induction_record_index
    participant_induction_records.index(induction_record)
  end

  def first_record?
    induction_record_index.zero?
  end

  def last_record?
    induction_record_index == (participant_induction_records.count - 1)
  end
end
