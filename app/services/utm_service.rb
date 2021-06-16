# frozen_string_literal: true

class UTMService
  CAMPAIGNS = {
    new_admin: "new-admin",
    new_lead_provider: "new-lead-provider",
    nominate_tutor: "nominate-tutor",
    new_induction_tutor: "new-induction-tutor",
    sign_in: "sign-in",
    challenge_partnership: "challenge-partnership",
    partnership_notification: "partnership-notification",
    june_private_beta: "june-private-beta",
  }.freeze

  SOURCES = {
    service: "cpdservice",
    private_beta: "cpdprivatebeta",
  }.freeze

  def self.email(campaign, source = :service)
    {
      utm_source: SOURCES[source] || "cpdservice",
      utm_medium: "email",
      utm_campaign: CAMPAIGNS[campaign] || "none",
    }
  end
end
