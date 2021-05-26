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
  }.freeze

  def self.email(campaign)
    {
      utm_source: "cpdservice",
      utm_medium: "email",
      utm_campaign: CAMPAIGNS[campaign] || "none",
    }
  end
end
