# frozen_string_literal: true

class ParticipantValidationService
  attr_reader :trn, :nino, :full_name, :date_of_birth, :config

  def self.validate(trn:, full_name:, date_of_birth:, nino:, config: {})
    new(trn:, full_name:, date_of_birth:, nino:, config:).validate
  end

  def initialize(trn:, full_name:, date_of_birth:, nino: nil, config: {})
    @trn = trn
    @full_name = full_name
    @date_of_birth = date_of_birth
    @nino = nino
    @config = config
  end

  def validate
    validated_record = matching_record(trn:, nino:, full_name:, dob: date_of_birth)
    return if validated_record.nil?

    {
      trn: validated_record["trn"],
      qts: validated_record.dig("qualified_teacher_status", "qts_date").present?,
      active_alert: validated_record["active_alert"],
      previous_participation: previous_participation?(validated_record),
      previous_induction: previous_induction?(validated_record),
      no_induction: validated_record.dig("induction", "start_date").nil?,
      exempt_from_induction: validated_record.dig("induction", "status") == "Exempt",
    }
  end

private

  def previous_participation?(validation_data)
    CheckParticipantPreviousParticipation.call(trn: validation_data["trn"])
  end

  def previous_induction?(validation_data)
    return false if validation_data["induction"].nil?
    return true if validation_data["induction"]["completion_date"].present?
    return false if validation_data["induction"]["start_date"].nil?

    # this should always be a check against 2021 not Cohort.current.start_year
    validation_data["induction"]["start_date"] < ActiveSupport::TimeZone["London"].local(2021, 9, 1)
  end

  def check_first_name_only?
    config[:check_first_name_only]
  end

  def dqt_record(trn, nino)
    full_dqt_client.get_record(trn:, birthdate: date_of_birth, nino:)
  end

  def full_dqt_client
    @full_dqt_client ||= FullDQT::Client.new
  end

  def matching_record(trn:, nino:, full_name:, dob:)
    return if trn.blank? && nino.blank?

    trn ||= "1"

    padded_trn = trn.rjust(7, "0")
    dqt_record = dqt_record(padded_trn, nino)
    return if dqt_record.nil? || dqt_record["state_name"] != "Active"

    matches = 0
    trn_matches = padded_trn == dqt_record["trn"]
    matches += 1 if trn_matches

    name_matches = if check_first_name_only?
                     full_name.split(" ").first.downcase == dqt_record["name"].split(" ").first.downcase
                   else
                     full_name.downcase == dqt_record["name"].downcase
                   end

    matches += 1 if name_matches

    dob_matches = dob == dqt_record["dob"]
    matches += 1 if dob_matches
    nino_matches = nino.present? && nino.downcase == dqt_record["ni_number"]&.downcase
    matches += 1 if nino_matches

    return dqt_record if matches >= 3

    # If a participant mistypes their TRN and enters someone else's, we should search by NINO instead
    # The API first matches by (mandatory) TRN, then by NINO if it finds no results. This works around that.
    if trn_matches && trn != "1"
      matching_record(trn: "1", nino:, full_name:, dob:)
    end
  end
end
