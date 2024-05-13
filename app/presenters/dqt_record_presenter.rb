# frozen_string_literal: true

class DQTRecordPresenter < SimpleDelegator
  INDUCTION_IN_PROGRESS = ["InProgress", "In Progress", "NotYetCompleted", "Not Yet Completed"].freeze

  def full_name
    [first_name, middle_name, last_name].filter(&:present?).join(" ")
  end

  def first_name
    dqt_record["firstName"] || dqt_record["name"]&.split(" ")&.first
  end

  def middle_name
    dqt_record["middleName"]
  end

  def last_name
    dqt_record["lastName"] || dqt_record["name"]&.split(" ")&.last
  end

  def trn
    dqt_record["trn"]
  end

  def active?
    dqt_record.present? || dqt_record&.fetch("state_name", nil) == "Active"
  end

  def dob
    dqt_record["dateOfBirth"] || dqt_record["dob"]
  end

  def ni_number
    dqt_record["nationalInsuranceNumber"] || dqt_record["ni_number"]
  end

  def active_alert?
    dqt_record["alerts"]&.any? || dqt_record["active_alert"].present?
  end

  def qts_date
    dqt_record.dig("qts", "awarded") || dqt_record.dig("qualified_teacher_status", "qts_date")
  end

  def induction_start_date
    induction_periods.to_a
                     .map { |period| period["startDate"] }
                     .compact
                     .min || dqt_record.dig("induction", "start_date")
  end

  def induction_completion_date
    induction_periods.to_a
                     .map { |period| period["endDate"] }
                     .compact
                     .max || dqt_record.dig("induction", "completion_date")
  end

  def exempt?
    dqt_record.dig("induction", "status") == "Exempt"
  end

  def induction_in_progress?
    INDUCTION_IN_PROGRESS.include?(dqt_record.dig("induction", "status"))
  end

private

  def induction_periods
    dqt_record.dig("induction", "periods")
  end

  def dqt_record
    __getobj__
  end
end
