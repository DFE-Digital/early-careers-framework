module Partnerships
  class Report
    CHALLENGE_WINDOW = 14.days.freeze
    REMINDER_EMAIL_DELAY = 7.days.freeze

    def self.call(**args)
      new(**args).call
    end

    def initialize(cohort_id:, school_id:, lead_provider_id:, delivery_partner_id:)
      @cohort_id = cohort_id
      @school_id = school_id
      @lead_provider_id = lead_provider_id
      @delivery_partner_id = delivery_partner_id
    end

    def call
      Partnership.transaction do
        partnership = Partnership.find_or_initialize_by(
          school_id: school_id,
          cohort_id: cohort_id,
          lead_provider_id: lead_provider_id,
        )

        partnership.challenge_reason = partnership.challenged_at = nil
        partnership.delivery_partner_id = delivery_partner_id
        partnership.pending = school_cohort.core_induction_programme?
        partnership.challenge_deadline = CHALLENGE_WINDOW.from_now
        partnership.save!

        partnership.event_logs.create!(
          event: :reported,
        )

        PartnershipNotificationService.new.delay.notify(partnership)
        PartnershipReminderJob.set(wait: REMINDER_EMAIL_DELAY).perform_later(partnership)

        if partnership.pending?
          PartnershipActivationJob.new.delay(run_at: CHALLENGE_WINDOW.from_now).perform(partnership)
        end

        partnership
      end
    end

  private

    attr_reader :cohort_id, :school_id, :lead_provider_id, :delivery_partner_id

    def school_cohort
      return @school_cohort if defined? @school_cohort

      @school_cohort = SchoolCohort.find_by(
        school_id: school_id,
        cohort_id: cohort_id
      )

      @school_cohort ||= SchoolCohort.create!(
        school_id: school_id,
        cohort_id: cohort_id,
        induction_programme_choice: "full_induction_programme",
      )
    end

    def partnership_pending?
      school_cohort.core_induction_programme?
    end
  end
end
