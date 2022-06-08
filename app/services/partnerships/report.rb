# frozen_string_literal: true

module Partnerships
  class Report < BaseService
    CHALLENGE_WINDOW = 14.days.freeze
    REMINDER_EMAIL_DELAY = 7.days.freeze

    def initialize(cohort_id:, school_id:, lead_provider_id:, delivery_partner_id:)
      @cohort_id = cohort_id
      @school_id = school_id
      @lead_provider_id = lead_provider_id
      @delivery_partner_id = delivery_partner_id
    end

    def call
      ActiveRecord::Base.transaction do
        partnership = Partnership.find_or_initialize_by(
          school_id:,
          cohort_id:,
          lead_provider_id:,
        )

        partnership.challenge_reason = partnership.challenged_at = nil
        partnership.delivery_partner_id = delivery_partner_id
        partnership.pending = delay_partnership?
        partnership.challenge_deadline = CHALLENGE_WINDOW.from_now
        partnership.report_id = SecureRandom.uuid
        partnership.save!

        # if a FIP has been chosen but the partnership was not present at the time
        # add it to the programme when it's reported
        Induction::ChangePartnership.call(school_cohort:,
                                          partnership:)

        partnership.event_logs.create!(
          event: :reported,
        )

        PartnershipNotificationJob.perform_later(partnership:)
        PartnershipReminderJob.set(wait: REMINDER_EMAIL_DELAY).perform_later(
          partnership:,
          report_id: partnership.report_id,
        )

        if partnership.pending?
          PartnershipActivationJob.set(wait_until: partnership.challenge_deadline).perform_later(
            partnership:,
            report_id: partnership.report_id,
          )
        end

        partnership
      end
    end

  private

    def delay_partnership?
      !school_cohort.full_induction_programme?
    end

    attr_reader :cohort_id, :school_id, :lead_provider_id, :delivery_partner_id

    def school_cohort
      return @school_cohort if defined? @school_cohort

      @school_cohort = SchoolCohort.find_by(
        school_id:,
        cohort_id:,
      )

      @school_cohort ||= SchoolCohort.create!(
        school_id:,
        cohort_id:,
        induction_programme_choice: "full_induction_programme",
      )
    end
  end
end
