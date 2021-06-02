# frozen_string_literal: true

class ParticipantValidationService
  def validate(trn:, nino:, full_name:, dob:)
    dqt_record = dqt_client.api.dqt_record.show(params: { teacher_reference_number: trn, national_insurance_number: nino })
    return false if dqt_record.nil?
    return false unless identity_matches?(trn, nino, full_name, dob, dqt_record)

    eligible?(dqt_record)
  end

private

  def dqt_client
    @dqt_client ||= Dqt::Client.new
  end

  def identity_matches?(trn, nino, full_name, dob, dqt_record)
    matches = 0
    trn_matches = trn == dqt_record[:teacher_reference_number]
    matches += 1 if trn_matches
    name_matches = full_name == dqt_record[:full_name]
    matches += 1 if name_matches
    dob_matches = dob == dqt_record[:date_of_birth]
    matches += 1 if dob_matches
    nino_matches = nino == dqt_record[:national_insurance_number]
    matches += 1 if nino_matches

    return true if matches >= 3

    # If a participant mistypes their TRN and enters someone else's, we should search by NINO instead
    # The API first matches by (mandatory) TRN, then by NINO if it finds no results. This works around that.
    if trn_matches && trn != "0"
      validate(trn: "0", nino: nino, full_name: full_name, dob: dob)
    else
      false
    end
  end

  def eligible?(dqt_record)
    dqt_record[:qts_date].present? && !dqt_record[:active_alert]
  end
end
