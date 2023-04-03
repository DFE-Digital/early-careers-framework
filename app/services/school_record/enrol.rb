# frozen_string_literal: true

class SchoolRecord::Enrol < BaseService
  def call
    ActiveRecord::Base.transaction do
      if leaving_date
        # update previous school record. Might need to pass school from/to
        previous_school_record.update(leaving_date:)
      end

      participant_profile.school_records.create!(
        school:,
        joining_date:,
      )
    end
  end

private

  attr_reader :participant_profile, :school, :joining_date, :leaving_date

  def initialize(participant_profile:, school:, joining_date:, leaving_date: nil)
    @participant_profile = participant_profile
    @school = school
    @joining_date = joining_date
    @leaving_date = leaving_date
  end

  def previous_school_record
    # participant_profile.school_records.latest
  end
end
