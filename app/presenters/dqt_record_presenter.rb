# frozen_string_literal: true

class DQTRecordPresenter < SimpleDelegator
  INDUCTION_IN_PROGRESS = ["InProgress", "In Progress", "NotYetCompleted", "Not Yet Completed"].freeze

  def name
    dqt_record["name"]
  end

  def trn
    dqt_record["trn"]
  end

  def active?
    dqt_record["state_name"] == "Active"
  end

  def dob
    dqt_record["dob"]
  end

  def ni_number
    dqt_record["ni_number"]
  end

  def active_alert?
    dqt_record["active_alert"].present?
  end

  def qts_date
    dqt_record.dig("qualified_teacher_status", "qts_date")
  end

  # This is a patch until we migrate this presenter from DQT::V1 to DQT::V3
  # The "induction", "start_date" coming in DQT::V1 is not the more accurate one so,
  # either we get it from the "induction" "periods" coming V1 or V3
  def induction_start_date
    @induction_start_date ||= (
      dqt_record.dig("induction", "periods") ||
        FullDQT::V3::Client.new.get_record(trn:)&.dig("induction", "periods")
    ).to_a
     .map { |period| period["startDate"] }
     .compact
     .min
  end

  def induction_completion_date
    dqt_record.dig("induction", "completion_date")
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
