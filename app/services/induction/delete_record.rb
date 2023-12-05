# frozen_string_literal: true

class Induction::DeleteRecord < BaseService
  def call
    ActiveRecord::Base.transaction do
      return unless deletable_record?

      update_previous_record
      delete_induction_record
    end
  end

private

  attr_reader :induction_record

  def initialize(induction_record:)
    @induction_record = induction_record
  end

  def deletable_record?
    middle_of_history? && transfer_flag_unchanged? && training_status_unchanged?
  end

  def middle_of_history?
    previous_record && next_record
  end

  def transfer_flag_unchanged?
    induction_record.school_transfer == previous_record.school_transfer
  end

  def training_status_unchanged?
    induction_record.training_status == previous_record.training_status
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
    induction_record
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
