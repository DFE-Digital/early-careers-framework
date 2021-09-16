# frozen_string_literal: true

class ValidateParticipant < BaseService
  attr_reader :participant_profile, :validation_data, :config

  def initialize(participant_profile:, validation_data: {}, config: {})
    @participant_profile = participant_profile
    @validation_data = validation_data.presence || fetch_validation_data
    @config = config
  end

  def call
    validation_result = query_dqt
    # TODO: what should we do with their eligibility record if this is a
    # revalidation and we can't match this time?
    if validation_result.nil?
      # if we always store the validation data it makes it difficult to reenter
      # or check answers in the UI flow as the presence of the validation data is
      # used to indicate the journey is complete.
      store_validation_data! if config.fetch(:save_validation_data_without_match, true)
      return false
    end

    @eligibility_data = store_eligibility_data!(validation_result)
    store_trn_on_teacher_profile!(validation_result[:trn])

    if @eligibility_data.eligible_status?
      remove_validation_data!
    else
      # store validation data for manual re-check later
      # if different TRN already exists or not eligible
      store_validation_data!
    end
    true
  rescue StandardError => e
    Rails.logger.error("Problem with DQT API: " + e.message)
    store_validation_data!(api_failure: true)
    raise
  end

private

  def fetch_validation_data
    participant_data = @participant_profile.ecf_participant_validation_data&.attributes
    participant_data ||= {}

    {
      trn: participant_data["trn"],
      name: participant_data["full_name"],
      date_of_birth: participant_data["date_of_birth"],
      national_insurance_number: participant_data["nino"],
    }
  end

  def store_eligibility_data!(dqt_data)
    record = ECFParticipantEligibility.find_or_initialize_by(participant_profile: participant_profile)
    record.qts = dqt_data[:qts]
    record.active_flags = dqt_data[:active_alert]
    record.previous_participation = dqt_data[:previous_participation]
    record.previous_induction = dqt_data[:previous_induction]
    record.determine_status
    record.save!
    record
  end

  def store_trn_on_teacher_profile!(trn)
    if participant_profile.teacher_profile.trn.present? && participant_profile.teacher_profile.trn != trn
      Rails.logger.warn("Different TRN already set for user [#{participant_profile.user.email}]")
      @eligibility_data.manual_check_status!
    else
      participant_profile.teacher_profile.update!(trn: trn)
    end
  end

  def store_validation_data!(opts = {})
    record = ECFParticipantValidationData.find_or_initialize_by(participant_profile: participant_profile)
    record.trn = validation_data[:trn]
    record.full_name = validation_data[:name]
    record.date_of_birth = validation_data[:date_of_birth]
    record.nino = validation_data[:national_insurance_number]
    record.api_failure = false
    record.assign_attributes(opts)
    record.save!
    record
  end

  def remove_validation_data!
    participant_profile.ecf_participant_validation_data&.destroy!
  end

  def query_dqt
    ParticipantValidationService.validate(trn: validation_data[:trn],
                                          full_name: validation_data[:name],
                                          date_of_birth: validation_data[:date_of_birth],
                                          nino: validation_data[:national_insurance_number],
                                          config: config.except(:save_validation_data_without_match))
  end
end
