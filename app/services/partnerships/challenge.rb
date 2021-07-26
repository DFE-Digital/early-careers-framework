# frozen_string_literal: true

module Partnerships
  class Challenge
    def self.call(partnership, challenge_reason)
      new(partnership, challenge_reason).call
    end

    def initialize(partnership, challenge_reason)
      @partnership = partnership
      @challenge_reason = challenge_reason
    end

    def call
      ActiveRecord::Base.transaction do
        partnership.challenge!(challenge_reason)
        partnership.event_logs.create!(
          event: :challenged,
          data: {
            reason: challenge_reason,
          },
        )

        if partnership.no_ects?
          school_cohort = partnership.school.school_cohorts.find_by(cohort: partnership.cohort)
          school_cohort.update!(induction_programme_choice: :no_early_career_teachers,
                                opt_out_of_updates: true)
        end

        partnership.lead_provider.users.each do |lead_provider_user|
          LeadProviderMailer.partnership_challenged_email(
            partnership: partnership,
            user: lead_provider_user,
          ).deliver_later
        end
      end
    end

  private

    attr_reader :partnership, :challenge_reason
  end
end
