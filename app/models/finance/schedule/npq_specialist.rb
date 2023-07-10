# frozen_string_literal: true

class Finance::Schedule::NPQSpecialist < Finance::Schedule::NPQ
  IDENTIFIERS = %w[
    npq-leading-teaching
    npq-leading-behaviour-culture
    npq-leading-teaching-development
    npq-leading-literacy
  ].freeze

  PERMITTED_COURSE_IDENTIFIERS = IDENTIFIERS

  def self.default_for(cohort: Cohort.current)
    find_by!(cohort:, schedule_identifier: "npq-specialist-spring")
  end

  def self.schedule_for(cohort: Cohort.current, schedule_date: Date.current)
    if autumn_schedule_2022?(schedule_date)
      find_by!(cohort:, schedule_identifier: "npq-specialist-autumn")
    elsif spring_schedule?(schedule_date)
      find_by!(cohort:, schedule_identifier: "npq-specialist-spring")
    elsif autumn_schedule?(schedule_date)
      find_by!(cohort:, schedule_identifier: "npq-specialist-autumn")
    else
      default_for(cohort:)
    end
  end

  def self.autumn_schedule_2022?(date)
    (Date.new(2022, 6, 1)..Date.new(2022, 12, 25)).include?(date)
  end

  def self.spring_schedule?(date)
    # Between: Dec 26 to Apr 2
    (Date.new(date.year, 1, 1)..Date.new(date.year, 4, 2)).include?(date) ||
      (Date.new(date.year, 12, 26)..Date.new(date.year, 12, 31)).include?(date)
  end

  def self.autumn_schedule?(date)
    # Between: Apr 3 to Dec 25
    (Date.new(date.year, 4, 3)..Date.new(date.year, 12, 25)).include?(date)
  end
end
