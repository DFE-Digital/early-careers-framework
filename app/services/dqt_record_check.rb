# frozen_string_literal: true

class DqtRecordCheck < ::BaseService
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
    @full_name = full_name
    @date_of_birth = date_of_birth
    @nino = nino
    @check_first_name_only = check_first_name_only
  end

  def dqt_record(trn, nino)
    full_dqt_client.get_record(trn:, birthdate: date_of_birth, nino:)
  end

  def full_dqt_client
    @full_dqt_client ||= FullDQT::Client.new
  end

  def check_record
    return check_failure(:trn_and_nino_blank) if trn.blank? && nino.blank?
    @trn = "0000001" if trn.blank?

    padded_trn = TeacherReferenceNumber.new(trn).formatted_trn
    dqt_record = dqt_record(padded_trn, nino)

    return check_failure(:no_match_found) if dqt_record.nil?
    return check_failure(:found_but_not_active) if dqt_record["state_name"] != "Active"

    matches = 0
    trn_matches = padded_trn == dqt_record["trn"]
    matches += 1 if trn_matches

    name_matches = if check_first_name_only?
                     full_name.split(" ").first.downcase == dqt_record["name"].split(" ").first.downcase
                   else
                     full_name.downcase == dqt_record["name"].downcase
                   end

    matches += 1 if name_matches

    dob_matches = date_of_birth == dqt_record["dob"]
    matches += 1 if dob_matches
    nino_matches = nino.present? && nino.downcase == dqt_record["ni_number"]&.downcase
    matches += 1 if nino_matches

    if matches < 3 && (trn_matches && trn != "1")
      # If a participant mistypes their TRN and enters someone else's, we should search by NINO instead
      # The API first matches by (mandatory) TRN, then by NINO if it finds no results. This works around that.
      @trn = "0000001"
      return check_record
    end

    CheckResult.new(dqt_record, trn_matches, name_matches, dob_matches, nino_matches, matches)
  end

  def check_failure(reason)
    CheckResult.new(nil, false, false, false, false, 0, reason)
  end

  # Helpers for tesing in review apps
  def magic_date_criteria_met?
    (Rails.env.development? || Rails.env.deployed_development?) && magic_date_range.include?(date_of_birth)
  end

  def magic_date_range
    (Date.new(1900, 1, 1)..Date.new(1900, 1, 3))
  end

  def magic_response
    magic_results[date_of_birth.day - 1]
  end

  def magic_results
    [
      # all matches - use birthdate 1/1/1900
      CheckResult.new(magic_dqt_record, true, true, true, true, 4), # dqt_record/TRN/name/DoB/Nino/total matched
      # name and nino don't match  - use birthdate 2/1/1900
      CheckResult.new(magic_dqt_record, true, false, true, false, 2),
      # did not match - use birthdate 3/1/1900
      check_failure(:no_match_found),
    ]
  end

  def magic_dqt_record
    {
      "trn" => trn,
      "name" => full_name,
      "dob" => date_of_birth,
      "ni_number" => nino,
      "active_alert" => false,
      "state_name" => "Active",
      "qualified_teacher_status" => {
        "qts_date" => 2.years.ago,
      },
      "induction" => {
        "start_date" => 1.month.ago,
        "status" => "In Progress",
      },
    }
  end
end
