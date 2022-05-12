# frozen_string_literal: true

class Induction::ChangeInductionRecord < BaseService
  def call
    ActiveRecord::Base.transaction do
      time_now = Time.zone.now

      new_record = induction_record.dup
      induction_record.changing!(time_now)

      new_record.assign_attributes(changes.reverse_merge(start_date: time_now))
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
