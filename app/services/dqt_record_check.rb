# frozen_string_literal: true

class DQTRecordCheck < ::BaseService
  TITLES = %w[mr mrs miss ms dr prof rev].freeze
  UNMATCHED_TRN = "0000001"

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
    return magic_dqt_record_check.call if magic_check_criteria_met?

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

  def fetch_dqt_record(trn)
    full_dqt_client.get_record(trn:)
  end

  def full_dqt_client
    @full_dqt_client ||= FullDQT::V3::Client.new
  end

  def check_record
    return check_failure(:trn_and_nino_blank) if trn.blank? && nino.blank?

    @trn = UNMATCHED_TRN if trn.blank?

    padded_trn = TeacherReferenceNumber.new(trn).formatted_trn
    dqt_record = DQTRecordPresenter.new(fetch_dqt_record(padded_trn))

    return check_failure(:no_match_found) if dqt_record.blank?

    trn_matches = dqt_record.trn == padded_trn
    name_matches = name_matches?(dqt_name: dqt_record.full_name)
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
        @trn = UNMATCHED_TRN
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

  def magic_dqt_record_check
    @magic_dqt_record_check ||= MagicDQTRecordCheck.new(trn, full_name, date_of_birth, nino)
  end

  def magic_check_criteria_met?
    return false if production_or_test_env?

    magic_dqt_record_check.date_range.include?(date_of_birth)
  end

  def production_or_test_env?
    Rails.env.production? || Rails.env.test?
  end
end
