# frozen_string_literal: true

class Cohort < ApplicationRecord
  has_paper_trail

  NPQ_PLUS_1_YEAR = 2020

  has_many :call_off_contracts
  has_many :npq_contracts
  has_many :partnerships
  has_many :schedules, class_name: "Finance::Schedule"
  has_many :statements

  has_one :academic_year

  scope :between_years, ->(lower, upper) { where(start_year: lower..upper) }
  scope :between_2021_and, ->(upper) { between_years(2021, upper) }
  scope :ordered_by_start_year, -> { order(start_year: :asc) }

  # Class Methods

  def self.active_ecf_registration_cohort
    where(ecf_registration_start_date: ..Date.current).order(start_year: :desc).first
  end

  def self.active_registration_cohort
    active_ecf_registration_cohort
  end
  alias_attribute :ecf_registration_start_date, :registration_start_date

  def self.active_npq_registration_cohort
    where(npq_registration_start_date: ..Date.current).order(start_year: :desc).first.presence || current
  end

  def self.containing_date(date)
    starting_within(date - 1.year + 1.day, date)
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

  def self.within_automatic_assignment_period?
    Time.zone.now <= Cohort.current.automatic_assignment_period_end_date
  end

  def self.within_next_registration_period?
    current != active_registration_cohort
  end

  def self.starting_within(start_date, end_date)
    find_by(academic_year_start_date: start_date..end_date)
  end
  private_class_method :starting_within

  # Instance Methods

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

  def npq_plus_one_or_earlier?
    start_year <= NPQ_PLUS_1_YEAR
  end

  def previous
    self.class.find_by(start_year: start_year - 1)
  end

  # e.g. "2022"
  def to_param
    start_year.to_s
  end
end
