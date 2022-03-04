# frozen_string_literal: true

class Cohort < ApplicationRecord
  has_many :schedules, class_name: "Finance::Schedule"
  has_many :partnerships

  def self.current
    # TODO: Register and Partner 262: Figure out how to update current year
    find_by(start_year: 2021)
  end

  def self.next
    find_by(start_year: 2022)
  end

  def display_name
    start_year.to_s
  end

  def academic_year
    # e.g. 2021/22
    "#{start_year}/#{start_year - 1999}"
  end

  def to_param
    start_year.to_s
  end
end
