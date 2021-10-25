# frozen_string_literal: true

class StoreValidationResult < BaseService
  attr_reader :participant_profile, :validation_data, :dtq_response

  def initialize(participant_profile:, validation_data:, dtq_response:)
    @participant_profile = participant_profile
    @validation_data = validation_data.presence || fetch_validation_data
    @dtq_response = dtq_response
  end

  def call
    eligibility = store_eligibility_data!(dtq_response)
    store_trn_on_teacher_profile!(dtq_response[:trn])
    store_validation_data!
    eligibility
  end

private

  def fetch_validation_data
    participant_data = @participant_profile.ecf_participant_validation_data&.attributes
    participant_data ||= {}

    {
      trn: participant_data["trn"],
      full_name: participant_data["full_name"],
      dob: participant_data["date_of_birth"],
      nino: participant_data["nino"],
    }
  end

  def store_eligibility_data!(dqt_data)
    StoreParticipantEligibility.call(participant_profile: participant_profile,
                                     eligibility_options: {
                                       qts: dqt_data[:qts],
                                       active_flags: dqt_data[:active_alert],
                                       previous_participation: dqt_data[:previous_participation],
                                       previous_induction: dqt_data[:previous_induction],
                                       different_trn: different_trn?(dqt_data[:trn]),
                                     })
  end

  def different_trn?(trn)
    participant_profile.teacher_profile.trn.present? && participant_profile.teacher_profile.trn != trn
  end

  def store_trn_on_teacher_profile!(trn)
    if different_trn?(trn)
      Rails.logger.warn("Different TRN already set for user [#{participant_profile.user.email}]")
    else
      participant_profile.teacher_profile.update!(trn: trn)
    end
  end

  def store_validation_data!
    record = ECFParticipantValidationData.find_or_initialize_by(participant_profile: participant_profile)
    record.assign_attributes(
      trn: validation_data[:trn],
      full_name: validation_data[:name],
      date_of_birth: validation_data[:dob],
      nino: validation_data[:nino],
    )
    record.tap(&:save!)
  end

  def remove_validation_data!
    participant_profile.ecf_participant_validation_data&.destroy!
  end
end
