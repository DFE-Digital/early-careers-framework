# frozen_string_literal: true

class AcademicYear < ApplicationRecord
  after_initialize :set_defaults

  IDENTIFIER_FORMAT = /\A\d{4}\/\d{2}\z/

  # e.g. "2021/22"
  validates :id,
            format: { with: IDENTIFIER_FORMAT, message: "must be in the format dddd/dd" },
            uniqueness: true
  alias_attribute :label, :id

  # e.g. "2020/21"
  validates :previous_id,
            format: { with: IDENTIFIER_FORMAT, message: "must be in the format dddd/dd" },
            allow_blank: true,
            uniqueness: true

  validates :start_date, presence: true
  validates :start_year, uniqueness: true, presence: true, numericality: { only_integer: true, less_than_or_equal_to: 9999 }
  validates :end_year, uniqueness: true, presence: true, numericality: { only_integer: true, less_than_or_equal_to: 9999 }

  validate :validate_configuration

  belongs_to :previous, class_name: "AcademicYear", optional: true
  has_one :next, class_name: "AcademicYear", foreign_key: :previous_id
  belongs_to :cohort, optional: true

  scope :starts_before_date, ->(date) { where(start_date: ...date) }
  scope :starts_after_date, ->(date) { where(start_date: date..) }
  scope :containing_date, ->(date) { left_outer_joins(:next).where(start_date: ..date).where("nexts_academic_years.start_date > ? OR nexts_academic_years IS NULL", date) }
  scope :for_date, ->(date) { containing_date(date).order(start_year: :desc) }

  scope :ecf_early_rollout_years, -> { where(ecf_early_rollout_year: true) }
  scope :ecf_national_rollout_years, -> { where(ecf_early_rollout_year: false) }

  class << self
    def last_ecf_early_rollout_year
      ecf_early_rollout_years.order(start_year: :desc).first
    end

    def first_ecf_national_rollout_year
      ecf_national_rollout_years.order(start_year: :asc).first
    end

    def now
      AcademicYear.containing_date(Time.zone.today).first
    end

    def id_from_year(year)
      sprintf("#{year}/%02d", ((year + 1) % 100))
    end
  end

  # e.g. "2021 to 2022"
  def description
    @description ||= "#{start_year} to #{end_year}"
  end

  # e.g. "2021"
  def display_name
    @display_name ||= start_year.to_s
  end

  delegate :ecf_registration_start_date, to: :cohort
  def ecf_registration_end_date
    @ecf_registration_end_date ||= self.next.cohort.registration_start_date - 1.day if self.next.present?
  end

  delegate :npq_registration_start_date, to: :cohort
  def npq_registration_end_date
    @npq_registration_end_date ||= self.next.cohort.npq_registration_start_date - 1.day if self.next.present?
  end

  def end_date
    @end_date ||= self.next.start_date - 1.day if self.next.present?
  end

  def is_ecf_early_rollout_year?
    ecf_early_rollout_year == true
  end

  def is_ecf_national_rollout_year?
    ecf_early_rollout_year == false
  end

private

  def set_defaults
    self.start_year ||= current_period.start_year
    self.end_year ||= current_period.end_year

    self.start_date ||= Date.new(start_year, 9, 1)

    self.cohort_id ||= Cohort.find_by(start_year:)&.id
    self.previous_id ||= AcademicYear.find_by(id: AcademicYear.id_from_year(start_year - 1))&.id
  end

  def validate_configuration
    return unless id.match(IDENTIFIER_FORMAT)

    errors.add(:id, "<#{id}> must represent two consecutive years not #{current_period.years} years") if current_period.years != 2

    errors.add(:start_date, "<#{start_date}> must have the year <#{start_year}>") if start_date.year != start_year

    errors.add(:cohort_id, "<#{cohort_id}> must be for the cohort with the same start_year not #{cohort.start_year} years") if cohort_id.present? && cohort.start_year != start_year

    if previous_id.present?
      return unless previous_id.match(IDENTIFIER_FORMAT)

      errors.add(:previous_id, "<#{previous_id}> must represent two consecutive years not #{previous_period.years} years") if previous_period.years != 2
      errors.add(:previous_id, "<#{previous_id}> must have the end year <#{start_year}>") if previous_period.end_year != start_year
    end
  end

  def current_period
    @current_period ||= CalendarDetails.new(id)
  end

  def previous_period
    @previous_period ||= CalendarDetails.new(previous_id)
  end

  CalendarDetails = Struct.new(
    :start_year,
    :end_year,
    :years,
  ) do
    def initialize(id)
      start_year, end_year = id.split("/").map(&:to_i)
      end_year ||= 0
      end_year = 100 if end_year.zero?
      end_year = start_year - (start_year % 100) + end_year
      years = (end_year - start_year) + 1

      self[:start_year] = start_year
      self[:end_year] = end_year
      self[:years] = years
    end
  end
end
