# frozen_string_literal: true

class MagicDQTRecordCheck
  def initialize(trn, full_name, date_of_birth, nino)
    @trn = trn
    @full_name = full_name&.strip
    @date_of_birth = date_of_birth
    @nino = nino
  end

  def call
    results[date_of_birth.day] || results[1]
  end

  def date_range
    results.keys.map { |k| Date.new(1900, 1, k) }
  end

private

  attr_reader :trn, :nino, :full_name, :date_of_birth

  def results
    {
      # all matches - use birthdate 1/1/1900
      1 => DQTRecordCheck::CheckResult.new(dqt_record, true, true, true, true, 4), # dqt_record/TRN/name/DoB/Nino/total matched

      # name and nino don't match  - use birthdate 2/1/1900
      2 => DQTRecordCheck::CheckResult.new(dqt_record, true, false, true, false, 2),

      # did not match - use birthdate 3/1/1900
      3 => DQTRecordCheck::CheckResult.new(nil, false, false, false, false, 0, :no_match_found),

      # matched but no QTS - use birthdate 4/1/1900
      4 => DQTRecordCheck::CheckResult.new(dqt_record(qts_date: nil), true, true, true, true, 4),

      # matched but no induction - use birthdate 5/1/1900
      5 => DQTRecordCheck::CheckResult.new(dqt_record(with_induction: false), true, true, true, true, 4),

      # matched but active flags - use birthdate 6/1/1900
      6 => DQTRecordCheck::CheckResult.new(dqt_record(active_alert: true), true, true, true, true, 4),

      # all matches 20 cohort start date - use 20/1/1900
      20 => DQTRecordCheck::CheckResult.new(dqt_record(induction_start_date: Date.new(2020, 9, 1)), true, true, true, true, 4),

      # all matches 21 cohort start date - use 21/1/1900
      21 => DQTRecordCheck::CheckResult.new(dqt_record(induction_start_date: Date.new(2021, 9, 1)), true, true, true, true, 4),

      # all matches 22 cohort start date - use 22/1/1900
      22 => DQTRecordCheck::CheckResult.new(dqt_record(induction_start_date: Date.new(2022, 9, 1)), true, true, true, true, 4),

      # all matches 23 cohort start date - use 23/1/1900
      23 => DQTRecordCheck::CheckResult.new(dqt_record(induction_start_date: Date.new(2023, 9, 1)), true, true, true, true, 4),
    }
  end

  def dqt_record(with_induction: true, qts_date: 2.years.ago, induction_start_date: 1.month.ago)
    record = {
      "trn" => TeacherReferenceNumber.new(trn).formatted_trn,
      "firstName" => full_name.split(" ").first,
      "lastName" => full_name.split(" ").last,
      "dateOfBirth" => date_of_birth,
      "nationalInsuranceNumber" => nino,
      "alerts" => %w[Alert],
      "qts" => {
        "awarded" => qts_date,
        "statusDescription" => "Active",
      },
    }

    if with_induction
      record.merge!("induction" => {
        "startDate" => induction_start_date,
        "status" => "In Progress",
      })
    end
    DQTRecordPresenter.new(record)
  end
end
