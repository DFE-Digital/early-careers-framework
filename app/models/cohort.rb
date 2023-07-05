# frozen_string_literal: true

class Cohort < ApplicationRecord
  has_paper_trail

  COHORTLESS_RELEASE_DATE = Cohort.find_by(start_year: 2023)&.registration_start_date || Date.new(2023, 6, 1)
  COHORTLESS_RELEASE_YEAR = COHORTLESS_RELEASE_DATE.year

  LAST_LOCAL_AUTHORITY_AB_YEAR = 2023

  NATIONAL_ROLLOUT_START_DATE = ActiveSupport::TimeZone["London"].local(2021, 9, 1)
  NATIONAL_ROLLOUT_FIRST_YEAR = NATIONAL_ROLLOUT_START_DATE.year

  EARLY_ROLLOUT_LAST_YEAR = NATIONAL_ROLLOUT_FIRST_YEAR - 1

  has_many :call_off_contracts
  has_many :npq_contracts
  has_many :partnerships
  has_many :schedules, class_name: "Finance::Schedule"
  has_many :statements

  scope :between_years, ->(lower, upper) { where(start_year: lower..upper) }
  scope :in_national_roll_out, ->(upper) { between_years(NATIONAL_ROLLOUT_FIRST_YEAR, upper) }
  scope :ordered_by_start_year, -> { order(start_year: :asc) }
  scope :current_national_rollout_year, -> { where(start_year: NATIONAL_ROLLOUT_FIRST_YEAR..Cohort.active_ecf_registration_cohort.start_year) }
  scope :national_rollout_year, -> { where(start_year: NATIONAL_ROLLOUT_FIRST_YEAR...) }

  # Class Methods

  def self.active_registration_cohort
    active_ecf_registration_cohort
  end

  def self.active_ecf_registration_cohort
    where(registration_start_date: ..Date.current).order(start_year: :desc).first
  end

  def self.active_npq_registration_cohort
    where(npq_registration_start_date: ..Date.current).order(start_year: :desc).first.presence || current
  end

  def self.valid_national_rollout_date?(start_date)
    # TODO: 1 year from now feels like it is flawed?
    # maybe it should be Cohort.active_ecf_registration_cohort.start_year + 1.year
    # as that is when the next registration cohort will become active?
    start_date.between?(NATIONAL_ROLLOUT_START_DATE, Date.current + 1.year)
  end

  def self.valid_early_rollout_date?(start_date)
    start_date < NATIONAL_ROLLOUT_START_DATE
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

  def self.within_ecf_automatic_assignment_period?
    Time.zone.now <= Cohort.current.automatic_assignment_period_end_date
  end

  def self.within_next_ecf_registration_period?
    current != active_ecf_registration_cohort
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

  def npq_plus_one_or_earlier?
    start_year < NATIONAL_ROLLOUT_FIRST_YEAR
  end

  def previous
    self.class.find_by(start_year: start_year - 1)
  end

  # e.g. "2022"
  def to_param
    start_year.to_s
  end
end
