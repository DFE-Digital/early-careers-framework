# frozen_string_literal: true

class Induction::ChangeInductionRecord < BaseService
  def call
    ActiveRecord::Base.transaction do
      time_now = Time.zone.now

      if induction_record.start_date > time_now
        induction_record.update!(changes)
      else
        new_record_end_date = [time_now, induction_record.end_date].max if induction_record.end_date
        default_attrs = {
          start_date: time_now,
          end_date: new_record_end_date,
          school_transfer: false,
        }
        new_record = induction_record.dup

        if induction_record.end_date.present? && induction_record.end_date > time_now
          default_attrs[:school_transfer] = induction_record.school_transfer?
          induction_record.update!(school_transfer: false)
        end

        induction_record.changing!(time_now)
        new_record.assign_attributes(default_attrs.merge(changes))
        new_record.save!
      end
    end
  end

private

  attr_reader :induction_record, :changes

  def initialize(induction_record:, changes: {})
    @induction_record = induction_record
    @changes = changes
  end
end
