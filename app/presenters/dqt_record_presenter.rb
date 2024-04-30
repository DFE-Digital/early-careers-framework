# frozen_string_literal: true

class DQTRecordPresenter < SimpleDelegator
  INDUCTION_IN_PROGRESS = ["InProgress", "In Progress", "NotYetCompleted", "Not Yet Completed"].freeze

  def full_name
    [first_name, middle_name, last_name].filter(&:present?).join(" ")
  end

  def first_name
    dqt_record["firstName"]
  end

  def middle_name
    dqt_record["middleName"]
  end

  def last_name
    dqt_record["lastName"]
  end

  def trn
    dqt_record["trn"]
  end

  def active?
    dqt_record.present?
  end

  def dob
    dqt_record["dateOfBirth"]
  end

  def ni_number
    dqt_record["nationalInsuranceNumber"]
  end

  def active_alert?
    dqt_record["alerts"]&.any?
  end

  def qts_date
    dqt_record.dig("qts", "awarded")
  end

  def induction_start_date
    dqt_record.dig("induction", "startDate")
  end

  def induction_completion_date
    dqt_record.dig("induction", "endDate")
  end

  def exempt?
    dqt_record.dig("induction", "status") == "Exempt"
  end

  def induction_in_progress?
    INDUCTION_IN_PROGRESS.include?(dqt_record.dig("induction", "status"))
  end

private

  def dqt_record
    __getobj__
  end
end
