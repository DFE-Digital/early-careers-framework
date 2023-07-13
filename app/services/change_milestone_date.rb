# frozen_string_literal: true

class ChangeMilestoneDate
  class DateCannotBeChangedError < RuntimeError; end

  DECLARATION_STATES_TO_IGNORE = %i[voided awaiting_clawback clawed_back].freeze

  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :schedule_identifier, :string
  attribute :start_year, :integer
  attribute :milestone_number, :integer
  attribute :new_start_date, :date
  attribute :new_milestone_date, :date

  validates :new_milestone_date, presence: { message: I18n.t(:milestone_date_required) }, if: -> { new_start_date.blank? }
  validates :new_start_date, presence: { message: I18n.t(:milestone_date_required) }, if: -> { new_milestone_date.blank? }
  validates :milestone, presence: { message: I18n.t(:milestone_not_matched) }
  validate :validate_milestone_dates_present
  validate :validate_milestone_date_change

  def change_date!
    raise DateCannotBeChangedError, errors.map(&:message) if invalid?

    updates = { start_date: new_start_date, milestone_date: new_milestone_date }.compact
    milestone.update!(updates)
  end

  def milestone
    return nil unless schedule

    @milestone ||= schedule.milestones.find do |m|
      m.name.start_with?("Output #{milestone_number} - ")
    end
  end

  def milestone_declarations
    return [] unless milestone

    ParticipantDeclaration::ECF
      .includes(:participant_profile)
      .where.not(state: DECLARATION_STATES_TO_IGNORE)
      .where(participant_profile: { schedule_id: schedule.id })
      .where(declaration_date: existing_date_range)
  end

private

  def validate_milestone_date_change
    milestone_declarations.map(&:declaration_date).each do |declaration_date|
      next if new_date_range.cover?(declaration_date)

      message = I18n.t(:cannot_change_milestone_date, declaration_date:, new_date_range:)
      errors.add(:new_milestone_date, message) if new_milestone_date
      errors.add(:new_start_date, message) if new_start_date
    end
  end

  def validate_milestone_dates_present
    return unless milestone

    errors.add(:milestone, I18n.t(:missing_start_date)) unless milestone.start_date
    errors.add(:milestone, I18n.t(:missing_milestone_date)) unless milestone.milestone_date
  end

  def existing_date_range
    milestone.start_date&.beginning_of_day..milestone.milestone_date&.end_of_day
  end

  def new_date_range
    (new_start_date || milestone.start_date).beginning_of_day..(new_milestone_date || milestone.milestone_date).end_of_day
  end

  def schedule
    @schedule ||= Finance::Schedule::ECF.find_by(schedule_identifier:, cohort:)
  end

  def cohort
    @cohort ||= Cohort.find_by(start_year:)
  end
end
