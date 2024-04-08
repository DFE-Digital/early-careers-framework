# frozen_string_literal: true

class Induction::ChangeInductionRecord < BaseService
  def call
    ActiveRecord::Base.transaction do
      time_now = Time.zone.now

      default_attrs = {
        start_date: time_now,
        school_transfer: false,
      }

      if induction_record.start_date > time_now
        induction_record.update!(changes)
      else
        default_attrs = {
          start_date: time_now,
          school_transfer: false,
        }
        new_record = induction_record.dup

        if induction_record.end_date.present?
          if induction_record.end_date < time_now
            # We're going to possibly be inserting a new record into an existing chain so
            # tweak the end date of the original record to make space for the new one
            adjusted_date = [induction_record.start_date, induction_record.end_date - 1.minute].max
            default_attrs[:start_date] = adjusted_date
            default_attrs[:end_date] = induction_record.end_date
            induction_record.update!(end_date: adjusted_date)
          else
            # future end date, move school transfer flag to new record
            default_attrs[:school_transfer] = induction_record.school_transfer?
            induction_record.update!(school_transfer: false)
            induction_record.changing!(time_now)
          end
        else
          induction_record.changing!(time_now)
        end

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
