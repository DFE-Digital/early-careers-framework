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
    sign_in_reminder: "sign-in-reminder",
    choose_route: "choose-route",
    choose_provider: "choose-provider",
    choose_materials: "choose-materials",
  }.freeze

  # Campaigns aren't showing up in GA at the moment, so use specific sources
  SOURCES = {
    service: "cpdservice",
    private_beta: "cpdprivatebeta",
    partnership_notification: "partnership-notification",
    nominate_tutor: "nominate-tutor",
    sign_in_reminder: "sign-in-reminder",
    choose_route: "choose-route",
    choose_provider: "choose-provider",
    choose_materials: "choose-materials",
  }.freeze

  def self.email(campaign, source = :service)
    {
      utm_source: SOURCES[source] || "cpdservice",
      utm_medium: "email",
      utm_campaign: CAMPAIGNS[campaign] || "none",
    }
  end
end
