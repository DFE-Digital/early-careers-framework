# frozen_string_literal: true

class Cohort < ApplicationRecord
  has_many :call_off_contracts
  has_many :npq_contracts
  has_many :partnerships
  has_many :schedules, class_name: "Finance::Schedule"
  has_many :statements

  scope :between_years, ->(lower, upper) { where(start_year: lower..upper) }
  scope :between_2021_and, ->(upper) { between_years(2021, upper) }

  # Class Methods

  def self.active_registration_cohort
    where(registration_start_date: ..Date.current).order(start_year: :desc).first
  end

  def self.active_npq_registration_cohort
    where(npq_registration_start_date: ..Date.current).order(start_year: :desc).first.presence || current
  end

  def self.current
    starting_within(Date.current - 1.year + 1.day, Date.current)
  end

  def self.next
    starting_within(Date.current + 1.day, Date.current + 1.year)
  end

  def self.previous
    starting_within(Date.current - 2.years + 1.day, Date.current - 1.year)
  end

  def self.starting_within(start_date, end_date)
    find_by(academic_year_start_date: start_date..end_date)
  end
  private_class_method :starting_within

  # Instance Methods

  # e.g. "2021/22"
  def academic_year
    sprintf("#{start_year}/%02d", ((start_year + 1) % 100))
  end

  # e.g. "2021 to 2022"
  def description
    "#{start_year} to #{start_year + 1}"
  end

  # e.g. "2021"
  def display_name
    start_year.to_s
  end

  def next
    self.class.find_by(start_year: start_year + 1)
  end

  def previous
    self.class.find_by(start_year: start_year - 1)
  end

  def self.containing_date(date)
    starting_within(date - 1.year + 1.day, date)
  end

  # e.g. "2022"
  def to_param
    start_year.to_s
  end
end
