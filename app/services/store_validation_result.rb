# frozen_string_literal: true

class StoreValidationResult < BaseService
  attr_reader :participant_profile, :validation_data, :dqt_response, :deduplicate

  def initialize(participant_profile:, validation_data:, dqt_response:, deduplicate: true)
    @participant_profile = participant_profile
    @validation_data = validation_data.presence || fetch_validation_data
    @dqt_response = dqt_response
    @deduplicate = deduplicate
  end

  def call
    store_validation_data!
    return unless dqt_response.valid?

    eligibility = store_eligibility_data!(dqt_response)
    store_trn_on_teacher_profile!(dqt_response.trn)
    deduplicate_by_trn! if deduplicate
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
    StoreParticipantEligibility.call(
      participant_profile:,
      eligibility_options: {
        qts: dqt_data.qts,
        active_flags: dqt_data.active_alert,
        previous_participation: dqt_data.previous_participation,
        previous_induction: dqt_data.previous_induction,
        no_induction: dqt_data.no_induction,
        exempt_from_induction: dqt_data.exempt_from_induction,
        different_trn: different_trn?(dqt_data.trn),
      },
    )
  end

  def different_trn?(trn)
    participant_profile.teacher_profile.trn.present? && participant_profile.teacher_profile.trn != trn
  end

  def store_trn_on_teacher_profile!(trn)
    if different_trn?(trn)
      Rails.logger.warn("Different TRN already set for user [#{participant_profile.user.email}]")
    else
      participant_profile.teacher_profile.update!(trn:)
    end
  end

  def store_validation_data!
    record = ECFParticipantValidationData.find_or_initialize_by(participant_profile:)
    record.assign_attributes(
      trn: validation_data[:trn],
      full_name: validation_data[:full_name],
      date_of_birth: validation_data[:dob],
      nino: validation_data[:nino],
    )
    record.tap(&:save!)
  end

  def remove_validation_data!
    participant_profile.ecf_participant_validation_data&.destroy!
  end

  def same_trn_user
    @same_trn_user ||= User
      .left_outer_joins(:teacher_profile)
      .where(teacher_profile: { trn: participant_profile.teacher_profile.trn })
      .where.not(teacher_profile: { id: participant_profile.teacher_profile.id })
      .first
  end

  def deduplicate_by_trn!
    return unless same_trn_user

    Identity::Transfer.call(from_user: participant_profile.user, to_user: same_trn_user)
  end
end
