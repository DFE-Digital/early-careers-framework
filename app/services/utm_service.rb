# frozen_string_literal: true

class UTMService
  CAMPAIGNS = {
    new_admin: "new-admin",
    new_lead_provider: "new-lead-provider",
    nominate_tutor: "nominate-tutor",
    nominate_tutor_cip_only: "nominate-tutor-cip-only",
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
    participant_validation_beta: "participant-validation-beta",
    participant_validation_research: "participant-validation-research",
    participant_validation_sit_notification: "participant-validation-sit-notification",
    check_ect_and_mentor_info: "check-ect-and-mentor-info",
    induction_coordinators_who_are_mentors_to_add_validation_information: "induction-coordinators-who-are-mentors-to-add-validation-information",
    asked_ects_and_mentors_for_information: "asked-ects-and-mentors-for-information",
    sit_to_complete_steps: "sit-to-complete-steps",
    year2020_nqt_invite_school: "year2020-nqt-invite-school",
    year2020_nqt_invite_sit: "year2020-nqt-invite-sit",
    ect_validation_info_2109: "ect-validation-info-2109",
    ect_validation_info_2709: "ect-validation-info-2709",
    mentor_validation_info_2309: "mentor-validation-info-2309",
    mentor_validation_info_2709: "mentor-validation-info-2709",
    sit_mentor_validation_info_2709: "sit-mentor-validation-info-2709",
    year2020_nqt_invite_school_not_opted_out: "year2020-nqt-invite-school-not-opted-out",
  }.freeze

  # Campaigns aren't showing up in GA at the moment, so use specific sources
  SOURCES = {
    service: "cpdservice",
    private_beta: "cpdprivatebeta",
    partnership_notification: "partnership-notification",
    nominate_tutor: "nominate-tutor",
    nominate_tutor_cip_only: "nominate-tutor-cip-only",
    sign_in_reminder: "sign-in-reminder",
    choose_route: "choose-route",
    choose_provider: "choose-provider",
    choose_materials: "choose-materials",
    add_participants: "add-participants",
    participant_validation_beta: "participant-validation-beta",
    participant_validation_research: "participant-validation-research",
    check_ect_and_mentor_info: "check-ect-and-mentor-info",
    induction_coordinators_who_are_mentors_to_add_validation_information: "induction-coordinators-who-are-mentors-to-add-validation-information",
    asked_ects_and_mentors_for_information: "asked-ects-and-mentors-for-information",
    sit_to_complete_steps: "sit-to-complete-steps",
    year2020_nqt_invite_school: "year2020-nqt-invite-school",
    year2020_nqt_invite_sit: "year2020-nqt-invite-sit",
    ect_validation_info_2109: "ect-validation-info-2109",
    mentor_validation_info_2309: "mentor-validation-info-2309",
    year2020_nqt_invite_school_not_opted_out: "year2020-nqt-invite-school-not-opted-out",
    ect_validation_info_2709: "ect-validation-info-2709",
    mentor_validation_info_2709: "mentor-validation-info-2709",
    sit_mentor_validation_info_2709: "sit-mentor-validation-info-2709",
  }.freeze

  def self.email(campaign, source = :service)
    {
      utm_source: SOURCES[source] || "cpdservice",
      utm_medium: "email",
      utm_campaign: CAMPAIGNS[campaign] || "none",
    }
  end
end
