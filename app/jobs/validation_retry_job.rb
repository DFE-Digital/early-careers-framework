# frozen_string_literal: true

class ValidationRetryJob < CronJob
  self.cron_expression = "15 3 * * *"

  queue_as :validation_retry

  def perform
    ECFParticipantValidationData.where(api_failure: true).each do |validation_data|
      validation_result = ParticipantValidationService.validate(trn: validation_data.trn,
                                                                full_name: validation_data.full_name,
                                                                date_of_birth: validation_data.date_of_birth,
                                                                nino: validation_data.nino)
      ActiveRecord::Base.transaction do
        validation_data.update!(api_failure: false)
        if validation_result.present?
          eligibility_data = store_eligibility_data!(validation_data, validation_result)
          eligibility_data.manual_check_status! unless store_trn!(validation_result[:trn], validation_data.participant_profile)

          validation_data.destroy! if eligibility_data.eligible_status?
        end
      end
    rescue StandardError => e
      Rails.logger.error("Problem with DQT API on retry: " + e.message)
      Sentry.capture_message("Problem with DQT API on retry: " + e.message)
      next
    end
  end

private

  def store_eligibility_data!(validation_data, validation_result)
    validation_data.participant_profile.create_ecf_participant_eligibility!(
      qts: validation_result[:qts],
      active_flags: validation_result[:active_alert],
      # TODO: CPDRP-672 use ERO data
      previous_participation: nil,
      # TODO: CPDRP-900 use previous induction data
      previous_induction: nil,
    )
  end

  def store_trn!(trn, participant_profile)
    if participant_profile.teacher_profile.trn.present? && participant_profile.teacher_profile.trn != trn
      Rails.logger.warn("Different TRN already set for user [#{participant_profile.user.email}]")
      false
    else
      participant_profile.teacher_profile.update!(trn: trn)
    end
  end
end
