# frozen_string_literal: true

class Induction::ChangeInductionRecord < BaseService
  def call
    ActiveRecord::Base.transaction do
      time_now = Time.zone.now

      new_record = induction_record.dup
      induction_record.changing!(time_now)

      default_attrs = {
        start_date: time_now,
        school_transfer: false,
      }

      if induction_record.start_date > time_now
        default_attrs[:start_date] = induction_record.start_date

        # transferring participant that hasn't started yet
        default_attrs[:school_transfer] = induction_record.school_transfer?
      end

      new_record.assign_attributes(default_attrs.merge(changes))
      new_record.save!
    end
  end

private

  attr_reader :induction_record, :changes

  def initialize(induction_record:, changes: {})
    @induction_record = induction_record
    @changes = changes
  end
end
