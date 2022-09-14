# frozen_string_literal: true

module Partnerships
  class Challenge < ::BaseService
    def call
      ActiveRecord::Base.transaction do
        challenge_partnership!
        update_school_cohort_for_no_ects! if partnership.no_ects?
      end

      send_notification_emails if notify_provider
    end

  private

    attr_reader :partnership, :challenge_reason, :notify_provider

    def initialize(partnership:, challenge_reason:, notify_provider: true)
      @partnership = partnership
      @challenge_reason = challenge_reason
      @notify_provider = notify_provider
    end

    def challenge_partnership!
      raise ArgumentError if challenge_reason.blank?

      partnership.update!(challenge_reason: challenge_reason, challenged_at: Time.zone.now)
      partnership.event_logs.create!(
        event: :challenged,
        data: {
          reason: challenge_reason,
        },
      )
    end

    def update_school_cohort_for_no_ects!
      school_cohort.update!(induction_programme_choice: :no_early_career_teachers,
                            default_induction_programme: nil,
                            opt_out_of_updates: true)
    end

    def send_notification_emails
      partnership.lead_provider.users.each do |lead_provider_user|
        LeadProviderMailer.partnership_challenged_email(
          partnership:,
          user: lead_provider_user,
        ).deliver_later
      end
    end

    def school_cohort
      partnership.school.school_cohorts.find_by(cohort: partnership.cohort)
    end
  end
end
