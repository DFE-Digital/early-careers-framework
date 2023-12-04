# frozen_string_literal: true

# This service class has all the logic needed to delete
# individual induction records and update the end_dates
# to maintain the induction record history
class Induction::DeleteRecord < BaseService
  def call
    ActiveRecord::Base.transaction do
      update_previous_record
      delete_induction_record
    end
    nil
  end

private

  attr_reader :induction_record

  def initialize(induction_record:)
    @induction_record = induction_record
  end

  def delete_induction_record
    induction_record.destroy
  end

  def update_previous_record
    return unless previous_record

    if next_record
      previous_record.update!(end_date: next_record.start_date)
    else
      previous_record.update!(end_date: nil)
    end
  end

  def previous_record
    participant_induction_records[induction_record_index + 1] unless last_record?
  end

  def next_record
    participant_induction_records[induction_record_index - 1] unless first_record?
  end

  def participant_induction_records
    induction_record.participant_profile.induction_records.order(start_date: :desc, created_at: :desc)
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
