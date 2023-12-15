# frozen_string_literal: true

class DQTRecordCheck < ::BaseService
  TITLES = %w[mr mrs miss ms dr prof rev].freeze

  CheckResult = Struct.new(
    :dqt_record,
    :trn_matches,
    :name_matches,
    :dob_matches,
    :nino_matches,
    :total_matched,
    :failure_reason,
  )

  def call
    if magic_date_criteria_met?
      return magic_response
    end

    check_record
  end

private

  attr_reader :trn, :nino, :full_name, :date_of_birth, :check_first_name_only
  alias_method :check_first_name_only?, :check_first_name_only

  def initialize(trn:, full_name:, date_of_birth:, nino: nil, check_first_name_only: true)
    @trn = trn
    @full_name = full_name&.strip
    @date_of_birth = date_of_birth
    @nino = nino
    @check_first_name_only = check_first_name_only
  end

  def dqt_record(trn, nino)
    record = full_dqt_client.get_record(trn:)
    # return nil unless record
    # return nil if record["nationalInsuranceNumber"] != nino
    # return nil if record["dateOfBirth"] != date_of_birth.to_date
    record
  end

  def full_dqt_client
    @full_dqt_client ||= FullDQT::V3::Client.new
  end

  def check_record
    return check_failure(:trn_and_nino_blank) if trn.blank? && nino.blank?

    @trn = "0000001" if trn.blank?

    padded_trn = TeacherReferenceNumber.new(trn).formatted_trn
    dqt_record = DQTRecordPresenter.new(dqt_record(padded_trn, nino))

    return check_failure(:no_match_found) if dqt_record.blank?
    return check_failure(:found_but_not_active) unless dqt_record.active?

    trn_matches = dqt_record.trn == padded_trn
    name_matches = name_matches?(dqt_name: dqt_record.name)
    dob_matches = dqt_record.dob == date_of_birth
    nino_matches = nino.present? && nino.downcase == dqt_record.ni_number&.downcase

    matches = [trn_matches, name_matches, dob_matches, nino_matches].count(true)

    if matches >= 3
      CheckResult.new(dqt_record, trn_matches, name_matches, dob_matches, nino_matches, matches)
    elsif matches < 3 && (trn_matches && trn != "1")
      if matches == 2 && !name_matches && check_first_name_only?
        CheckResult.new(dqt_record, trn_matches, name_matches, dob_matches, nino_matches, matches)
      else
        # If a participant mistypes their TRN and enters someone else's, we should search by NINO instead
        # The API first matches by (mandatory) TRN, then by NINO if it finds no results. This works around that.
        @trn = "0000001"
        check_record
      end
    else
      # we found a record but not enough matched
      check_failure(:no_match_found)
    end
  end

  def name_matches?(dqt_name:)
    return false if full_name.blank?
    return false if full_name.in?(TITLES)
    return false if dqt_name.blank?

    NameMatcher.new(full_name, dqt_name, check_first_name_only:).matches?
  end

  def check_failure(reason)
    CheckResult.new(nil, false, false, false, false, 0, reason)
  end

  # Helpers for tesing in review apps
  def magic_date_criteria_met?
    (!Rails.env.production? && !Rails.env.test?) && magic_date_range.include?(date_of_birth)
  end

  def magic_date_range
    magic_results.keys.map { |k| Date.new(1900, 1, k) }
  end

  def magic_response
    magic_results[date_of_birth.day] || magic_results[1]
  end

  def magic_results
    {
      # all matches - use birthdate 1/1/1900
      1 => CheckResult.new(magic_dqt_record, true, true, true, true, 4), # dqt_record/TRN/name/DoB/Nino/total matched

      # name and nino don't match  - use birthdate 2/1/1900
      2 => CheckResult.new(magic_dqt_record, true, false, true, false, 2),

      # did not match - use birthdate 3/1/1900
      3 => check_failure(:no_match_found),

      # matched but no QTS - use birthdate 4/1/1900
      4 => CheckResult.new(magic_dqt_record(qts_date: nil), true, true, true, true, 4),

      # matched but no induction - use birthdate 5/1/1900
      5 => CheckResult.new(magic_dqt_record(with_induction: false), true, true, true, true, 4),

      # matched but active flags - use birthdate 6/1/1900
      6 => CheckResult.new(magic_dqt_record(active_alert: true), true, true, true, true, 4),

      # all matches 20 cohort start date - use 20/1/1900
      20 => CheckResult.new(magic_dqt_record(induction_start_date: Date.new(2020, 9, 1)), true, true, true, true, 4),

      # all matches 21 cohort start date - use 21/1/1900
      21 => CheckResult.new(magic_dqt_record(induction_start_date: Date.new(2021, 9, 1)), true, true, true, true, 4),

      # all matches 22 cohort start date - use 22/1/1900
      22 => CheckResult.new(magic_dqt_record(induction_start_date: Date.new(2022, 9, 1)), true, true, true, true, 4),

      # all matches 23 cohort start date - use 23/1/1900
      23 => CheckResult.new(magic_dqt_record(induction_start_date: Date.new(2023, 9, 1)), true, true, true, true, 4),
    }
  end

  def magic_dqt_record(with_induction: true, active_alert: false, qts_date: 2.years.ago, induction_start_date: 1.month.ago)
    record = {
      "trn" => TeacherReferenceNumber.new(trn).formatted_trn,
      "name" => full_name,
      "dob" => date_of_birth,
      "ni_number" => nino,
      "active_alert" => active_alert,
      "state_name" => "Active",
      "qualified_teacher_status" => {
        "qts_date" => qts_date,
      },
    }

    if with_induction
      record.merge!("induction" => {
        "start_date" => induction_start_date,
        "status" => "In Progress",
      })
    end
    DQTRecordPresenter.new(record)
  end
end
