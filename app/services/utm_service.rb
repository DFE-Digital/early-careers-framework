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
    add_participants: "add-participants",
    year2020_nqt_invite: "year2020-nqt-invite",
    participant_validation_beta: "participant-validation-beta",
    participant_validation_research: "participant-validation-research",
    participant_validation_sit_notification: "participant-validation-sit-notification",
    check_ect_and_mentor_info: "check-ect-and-mentor-info",
    we_need_information_for_your_programme: "we-need-information-for-your-programme",
    asked_ects_and_mentors_for_information: "asked-ects-and-mentors-for-information",
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
    add_participants: "add-participants",
    year2020_nqt_invite: "year2020-nqt-invite",
    participant_validation_beta: "participant-validation-beta",
    participant_validation_research: "participant-validation-research",
    check_ect_and_mentor_info: "check-ect-and-mentor-info",
    we_need_information_for_your_programme: "we-need-information-for-your-programme",
    asked_ects_and_mentors_for_information: "asked-ects-and-mentors-for-information",
  }.freeze

  def self.email(campaign, source = :service)
    {
      utm_source: SOURCES[source] || "cpdservice",
      utm_medium: "email",
      utm_campaign: CAMPAIGNS[campaign] || "none",
    }
  end
end
