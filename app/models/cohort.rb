# frozen_string_literal: true

class Cohort < ApplicationRecord
  has_many :call_off_contracts
  has_many :npq_contracts
  has_many :partnerships
  has_many :schedules, class_name: "Finance::Schedule"
  has_many :statements

  # Class Methods
  def self.active_registration_cohort
    where(registration_start_date: ..Date.current).order(start_year: :desc).first
  end

  def self.current
    where(academic_year_start_date: ..Date.current).order(start_year: :desc).first
  end

  def self.next
    where.not(academic_year_start_date: ..Date.current).order(start_year: :asc).first
  end

  # Instance Methods
  # e.g. "2021/22"
  def academic_year
    sprintf("#{start_year}/%02d", ((start_year + 1) % 100))
  end

  def description
    "#{start_year} to #{start_year + 1}"
  end

  def display_name
    start_year.to_s
  end

  def next
    Cohort.find_by(start_year: start_year + 1)
  end

  def previous
    Cohort.find_by(start_year: start_year - 1)
  end

  def to_param
    start_year.to_s
  end
end
