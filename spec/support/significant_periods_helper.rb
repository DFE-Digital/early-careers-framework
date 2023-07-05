# frozen_string_literal: true

module SignificantPeriodsHelper
  PeriodHelper = Struct.new(
    :start_date,
    :end_date,
    :current_year,
    :next_year,
    keyword_init: true,
  ) do
    def start_year = start_date.year
    def first_year = start_year
    def previous_year = current_year - 1
    def end_year = end_date.year
    def last_year = end_year - 1

    def start_cohort = @start_cohort ||= Cohort.find_by(start_year:)
    def first_cohort = start_cohort
    def previous_cohort = @previous_cohort ||= Cohort.find_by(start_year: previous_year)
    def current_cohort = @current_cohort ||= Cohort.find_by(start_year: current_year)
    def cohort = current_cohort
    def next_cohort = @next_cohort ||= Cohort.find_by(start_year: next_year)
    def last_cohort = @last_cohort ||= Cohort.find_by(start_year: last_year)
  end

  ECF_EARLY_ROLLOUT = PeriodHelper.new(
    end_date: Date.new(2021, 8, 31),
  )

  ECF_NATIONAL_ROLLOUT = PeriodHelper.new(
    start_date: Date.new(2021, 9, 1),
    current_year: 2022,
    next_year: 2023,
  )

  ECF_COHORTLESS_PILOT = PeriodHelper.new(
    start_date: Date.new(2023, 6, 1),
    end_date: Date.new(2023, 7, 1),
  )

  def last_ecf_early_rollout_cohort = ECF_EARLY_ROLLOUT.last_cohort

  def first_ecf_national_rollout_cohort = ECF_NATIONAL_ROLLOUT.first_cohort
  def previous_ecf_national_rollout_cohort = ECF_NATIONAL_ROLLOUT.previous_cohort
  def current_ecf_national_rollout_cohort = ECF_NATIONAL_ROLLOUT.current_cohort
  def next_ecf_national_rollout_cohort = ECF_NATIONAL_ROLLOUT.next_cohort

  def before_current_ecf_registration_window_starts(&block)
    taking_place_before(ECF_NATIONAL_ROLLOUT.current_cohort.registration_start_date, &block)
  end

  def after_current_ecf_registration_window_starts(&block)
    taking_place_after(ECF_NATIONAL_ROLLOUT.current_cohort.registration_start_date, &block)
  end

  def before_current_ecf_registration_window_ends(&block)
    taking_place_before(ECF_NATIONAL_ROLLOUT.next_cohort.registration_start_date, &block)
  end

  def after_current_ecf_registration_window_ends(&block)
    taking_place_after(ECF_NATIONAL_ROLLOUT.next_cohort.registration_start_date, &block)
  end

  def before_current_ecf_auto_assignment_window_ends(&block)
    taking_place_before(ECF_NATIONAL_ROLLOUT.current_cohort.automatic_assignment_period_end_date, &block)
  end

  def after_current_ecf_auto_assignment_window_ends(&block)
    taking_place_after(ECF_NATIONAL_ROLLOUT.current_cohort.automatic_assignment_period_end_date, &block)
  end

  def taking_place_before(significant_date, &block)
    travel_to(significant_date - 1.week, &block)
  end

  def taking_place_after(significant_date, &block)
    travel_to(significant_date + 1.week, &block)
  end
end
