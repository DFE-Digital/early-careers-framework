# frozen_string_literal: true

class SchoolMailer < ApplicationMailer
  NOMINATION_EMAIL_TEMPLATE = "a7cc4d19-c0cb-4187-a71b-1b1ea029924f"
  NOMINATION_CONFIRMATION_EMAIL_TEMPLATE = "2c740b37-bc4e-47eb-8657-1742b9b8eda7"
  SCHOOL_REQUESTED_SIGNIN_LINK_FROM_GIAS = "f2764570-ca3c-4e3b-97c3-251a853c9dde"
  SCHOOL_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE = "8cac177e-b094-4a00-9179-94fadde8ced0"
  COORDINATOR_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE = "076e8486-cbcc-44ee-8a6e-d2a721ee1460"
  MINISTERIAL_LETTER_EMAIL_TEMPLATE = "f1310917-aa50-4789-b8c2-8cc5e9b91485"
  BETA_INVITE_EMAIL_TEMPLATE = "0ae827de-3caa-4a93-b464-c434cbbd02c0"
  MAT_INVITE_EMAIL_TEMPLATE = "f856f50e-6f49-441e-8018-f8303367eb5c"
  CIP_ONLY_INVITE_EMAIL_TEMPLATE = "ee814b67-52e3-409d-8350-5140e6741124"
  FEDERATION_INVITE_EMAIL_TEMPLATE = "9269c50d-b579-425b-b55b-4c93f67074d4"
  SECTION_41_INVITE_EMAIL_TEMPLATE = "a4ba1de4-e401-47f4-ac77-60c1da17a0e5"
  UNENGAGED_INVITE_EMAIL_TEMPLATE = "a7cc4d19-c0cb-4187-a71b-1b1ea029924f"
  COORDINATOR_SIGN_IN_CHASER_EMAIL_TEMPLATE = "b5c318a4-2171-4ded-809a-af72dd87e7a7"
  COORDINATOR_REMINDER_TO_CHOOSE_ROUTE_EMAIL_TEMPLATE = "c939c27a-9951-4ac3-817d-56b7bf343fb4"
  UNPARTNERED_FIP_CHASER_EMAIL_TEMPLATE = "41fe132b-d0bd-4b94-8feb-536701d79fc6"
  COORDINATOR_REMINDER_TO_CHOOSE_MATERIALS_EMAIL_TEMPLATE = "43baf25c-6a46-437b-9f30-77c57d68a59e"
  ADD_PARTICIPANTS_EMAIL_TEMPLATE = "721787d0-74bc-42a0-a064-ee0c1cb58edb"
  REMIND_FIP_TO_ADD_ECTS_AND_MENTORS_EMAIL_TEMPLATE = "63f9fe5b-aff1-4cf7-9593-6843b80d4044"
  NQT_PLUS_ONE_SITLESS_EMAIL_TEMPLATE = "c10392e4-9d75-402d-a7fd-47df16fa6082"
  NQT_PLUS_ONE_SIT_EMAIL_TEMPLATE = "9e01b5ac-a94c-4c71-a38d-6502d7c4c2e7"
  DIY_WORDPRESS_NOTIFICATION_TEMPLATE = "e1067a2f-b027-45a6-8e51-668e170090d1"
  PARTNERED_SCHOOL_INVITE_SIT_EMAIL_TEMPLATE = "8cac177e-b094-4a00-9179-94fadde8ced0"
  UNPARTNERED_CIP_SIT_ADD_PARTICIPANTS_EMAIL_TEMPLATE = "ebc96223-c2ea-416e-8d3e-1f591bbd2f98"
  SIT_NEW_AMBITION_ECTS_AND_MENTORS_ADDED_TEMPLATE = "90d86c1b-2dca-4cca-9dcb-5940e7f28577"
  SIT_FIP_PARTICIPANT_VALIDATION_DEADLINE_REMINDER_TEMPLATE = "48f63205-a8d9-49a2-a76c-93d48ec9b23b"
  SCHOOL_PRETERM_REMINDER = "a7cc4d19-c0cb-4187-a71b-1b1ea029924f"
  PARTICIPANT_WITHDRAWN_BY_PROVIDER = "29f94916-8c3a-4c5a-9e33-bdf3f5d7249a"
  REMIND_TO_SETUP_MENTOR_TO_ECTS = "604ca80f-b152-4682-9295-9cf1d30f74c1"
  REMIND_GIAS_CONTACT_TO_UPDATE_INDUCTION_TUTOR_DETAILS_TEMPLATE = "88cdad72-386c-40fb-be2e-11d4ae9dcdee"

  def remind_sit_to_set_mentor_to_ects(sit:, ect_names:, campaign: nil)
    campaign_tracking = campaign ? UTMService.email(campaign, campaign) : {}

    template_mail(
      REMIND_TO_SETUP_MENTOR_TO_ECTS,
      to: sit.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        sit_name: sit.full_name,
        ect_names:,
        sign_in: new_user_session_url(**campaign_tracking),
      },
    ).tag(:sit_to_set_mentor_to_ects).associate_with(sit.induction_coordinator_profile)
  end

  # This email is currently (30/09/2021) only used for manually sent chaser emails
  def remind_induction_coordinator_to_setup_cohort_email(induction_coordinator_profile:, school_name:, campaign: nil)
    campaign_tracking = campaign ? UTMService.email(campaign, campaign) : {}

    template_mail(
      "14aabb56-1d6e-419f-8144-58a0439c61a6",
      to: induction_coordinator_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        subject: "You need to set up your ECT training programme",
        school_name:,
        sign_in: new_user_session_url(**campaign_tracking),
        step_by_step: step_by_step_url(**campaign_tracking),
      },
    ).tag(:sit_to_complete_steps).associate_with(induction_coordinator_profile)
  end

  # This email is sent to schools to request an appointment of SIT to coordinate their cohorts
  def nomination_email(recipient:, school:, nomination_url:, expiry_date:)
    template_mail(
      NOMINATION_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school.name,
        nomination_link: nomination_url,
        expiry_date:,
      },
    ).tag(:request_to_nominate_sit).associate_with(school)
  end

  # This email lets the GIAS contact at a school update their induction tutor
  def remind_to_update_school_induction_tutor_details(school:, sit_name:, nomination_link:)
    template_mail(
      REMIND_GIAS_CONTACT_TO_UPDATE_INDUCTION_TUTOR_DETAILS_TEMPLATE,
      to: [school.primary_contact_email, school.secondary_contact_email].compact.uniq,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: { sit_name:, nomination_link: },
    ).tag(:remind_to_update_induction_tutor).associate_with(school)
  end

  # This email is sent to newly appointed SIT
  def nomination_confirmation_email(sit_profile:, school:, start_url:, step_by_step_url:)
    template_mail(
      NOMINATION_CONFIRMATION_EMAIL_TEMPLATE,
      to: sit_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: sit_profile.user.full_name,
        school_name: school.name,
        start_page: start_url,
        subject: "Sign in to manage induction",
        step_by_step: step_by_step_url,
      },
    ).tag(:sit_nominated).associate_with(school, sit_profile)
  end

  # This email is sent when induction tutor to be changed
  def school_requested_signin_link_from_gias_email(school:, nomination_link:)
    template_mail(
      SCHOOL_REQUESTED_SIGNIN_LINK_FROM_GIAS,
      to: school.primary_contact_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school.name,
        nomination_link:,
      },
    ).tag(:school_signin_link).associate_with(school)
  end

  # This email is sent to the school which has been reported by the lead provider and which hasn't yet nominated SIT
  # It also contains request to nominate SIT.
  def school_partnership_notification_email(recipient:, partnership:, challenge_url:, nominate_url:)
    template_mail(
      SCHOOL_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        lead_provider_name: partnership.lead_provider.name,
        delivery_partner_name: partnership.delivery_partner.name,
        school_name: partnership.school.name,
        nominate_url:,
        challenge_url:,
        challenge_deadline: partnership.challenge_deadline&.to_date&.to_s(:govuk),
        subject: "FAO: NQT coordinator. Training provider confirmed.",
      },
    ).tag(:partnership_created, :request_to_nominate_sit).associate_with(partnership, partnership.school)
  end

  def partnered_school_invite_sit_email(
    recipient:,
    school:,
    lead_provider_name:,
    delivery_partner_name:,
    nominate_url:,
    challenge_url:
  )

    template_mail(
      PARTNERED_SCHOOL_INVITE_SIT_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school.name,
        lead_provider_name:,
        delivery_partner_name:,
        nominate_url:,
        challenge_url:,
      },
    ).tag(:partnered_school_invite_sit).associate_with(school)
  end

  # This email is sent to the SIT of the school whe was reported to enter the partnership with lead provider.
  # If given school has no appointed SIT, the `school_partnership_notification_email` should be sent instead
  def coordinator_partnership_notification_email(coordinator:, partnership:, sign_in_url:, challenge_url:)
    template_mail(
      COORDINATOR_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE,
      to: coordinator.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: coordinator.full_name,
        lead_provider_name: partnership.lead_provider.name,
        delivery_partner_name: partnership.delivery_partner.name,
        school_name: partnership.school.name,
        sign_in_url:,
        challenge_url:,
        challenge_deadline: partnership.challenge_deadline,
        step_by_step: step_by_step_url,
        subject: "Training provider confirmed: add your ECTs and mentors",
      },
    ).tag(:partnership_created).associate_with(partnership, partnership.school)
  end

  def ministerial_letter_email(recipient:)
    template_mail(
      MINISTERIAL_LETTER_EMAIL_TEMPLATE,
      to: recipient,
      reply_to_id: "84c368c3-4ff0-4b81-93d3-bc75291f4153",
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        letter_url: Rails.application.routes.url_helpers.ministerial_letter_url(host: Rails.application.config.domain),
        leaflet_url: Rails.application.routes.url_helpers.ecf_leaflet_url(host: Rails.application.config.domain),
      },
    )
  end

  def beta_invite_email(recipient:, name:, school_name:, start_url:)
    template_mail(
      BETA_INVITE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name:,
        school_name:,
        start_url:,
      },
    )
  end

  def mat_invite_email(recipient:, school_name:, nomination_url:)
    template_mail(
      MAT_INVITE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name:,
        nomination_url:,
      },
    )
  end

  def federation_invite_email(recipient:, school_name:, nomination_url:)
    template_mail(
      FEDERATION_INVITE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name:,
        nomination_url:,
      },
    )
  end

  def cip_only_invite_email(recipient:, school_name:, nomination_url:)
    template_mail(
      CIP_ONLY_INVITE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name:,
        nomination_link: nomination_url,
      },
    )
  end

  def section_41_invite_email(recipient:, school_name:, nomination_url:)
    template_mail(
      SECTION_41_INVITE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name:,
        nomination_link: nomination_url,
      },
    )
  end

  def unengaged_schools_email(recipient:, school:, nomination_url:)
    template_mail(
      UNENGAGED_INVITE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school.name,
        nomination_link: nomination_url,
      },
    ).tag(:unengaged_school_email).associate_with(school)
  end

  def induction_coordinator_sign_in_chaser_email(recipient:, name:, school_name:, sign_in_url:)
    template_mail(
      COORDINATOR_SIGN_IN_CHASER_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name:,
        school_name:,
        sign_in_url:,
      },
    )
  end

  def induction_coordinator_reminder_to_choose_route_email(recipient:, name:, school_name:, sign_in_url:)
    template_mail(
      COORDINATOR_REMINDER_TO_CHOOSE_ROUTE_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name:,
        school_name:,
        sign_in_url:,
      },
    )
  end

  def induction_coordinator_reminder_to_choose_provider_email(induction_coordinator:, school:)
    template_mail(
      UNPARTNERED_FIP_CHASER_EMAIL_TEMPLATE,
      to: induction_coordinator.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: induction_coordinator.full_name,
        school_name: school.name,
      },
    ).tag(:chase_unpartnered_fip_schools).associate_with(school, as: :school)
  end

  def induction_coordinator_reminder_to_choose_materials_email(recipient:, name:, school_name:, sign_in_url:)
    template_mail(
      COORDINATOR_REMINDER_TO_CHOOSE_MATERIALS_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name:,
        school_name:,
        sign_in_url:,
        step_by_step: step_by_step_url,
      },
    )
  end

  def induction_coordinator_add_participants_email(recipient:, name:, sign_in_url:)
    template_mail(
      ADD_PARTICIPANTS_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name:,
        sign_in_url:,
      },
    )
  end

  def remind_fip_induction_coordinators_to_add_ects_and_mentors_email(induction_coordinator:, school_name:, campaign: nil)
    campaign_tracking = campaign ? UTMService.email(campaign, campaign) : {}

    template_mail(
      REMIND_FIP_TO_ADD_ECTS_AND_MENTORS_EMAIL_TEMPLATE,
      to: induction_coordinator.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: induction_coordinator.user.full_name,
        school_name:,
        sign_in: new_user_session_url(**campaign_tracking),
      },
    ).tag(:fifth_request_to_add_ects_and_mentors).associate_with(induction_coordinator, as: :induction_coordinator_profile)
  end

  def nqt_plus_one_sitless_invite(recipient:, start_url:)
    template_mail(
      NQT_PLUS_ONE_SITLESS_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        start_url:,
      },
    )
  end

  def nqt_plus_one_sit_invite(recipient:, start_url:, school:)
    template_mail(
      NQT_PLUS_ONE_SIT_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        start_url:,
      },
    ).tag(:year2020_invite).associate_with(school, as: :school)
  end

  def unpartnered_cip_sit_add_participants_email(recipient:, induction_coordinator:, sign_in_url:, school_name:)
    template_mail(
      UNPARTNERED_CIP_SIT_ADD_PARTICIPANTS_EMAIL_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        sign_in: sign_in_url,
        school_name:,
      },
    ).tag(:unpartnered_cip_add_participants).associate_with(induction_coordinator, as: :induction_coordinator)
  end

  def diy_wordpress_notification(user:)
    template_mail(
      DIY_WORDPRESS_NOTIFICATION_TEMPLATE,
      to: user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        sit_name: user.full_name,
      },
    ).tag(:diy_wordpress_notification)
  end

  def sit_new_ambition_ects_and_mentors_added_email(induction_coordinator_profile:, sign_in_url:, school_name:)
    template_mail(
      SIT_NEW_AMBITION_ECTS_AND_MENTORS_ADDED_TEMPLATE,
      to: induction_coordinator_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        sign_in: sign_in_url,
        school_name:,
      },
    ).tag(:sit_new_ambition_participants_added).associate_with(induction_coordinator_profile, as: :induction_coordinator)
  end

  def sit_fip_participant_validation_deadline_reminder_email(induction_coordinator_profile:, participant_name_list:, participant_start_url:, sign_in_url:)
    template_mail(
      SIT_FIP_PARTICIPANT_VALIDATION_DEADLINE_REMINDER_TEMPLATE,
      to: induction_coordinator_profile.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: induction_coordinator_profile.user.full_name,
        participant_name_list:,
        participant_start: participant_start_url,
        sign_in: sign_in_url,
      },
    ).tag(:sit_fip_participant_validation_deadline_reminder).associate_with(induction_coordinator_profile, as: :induction_coordinator)
  end

  def school_preterm_reminder(school:, season:)
    nomination_email = NominationEmail.create_nomination_email(
      sent_at: Time.zone.now,
      sent_to: school.contact_email,
      school:,
    )

    template_mail(
      SCHOOL_PRETERM_REMINDER,
      to: school.contact_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        season:,
        school_name: school.name,
        nomination_link: nomination_email.nomination_url,
      },
    ).tag(:school_preterm_reminder).associate_with(school)
  end

  def fip_provider_has_withdrawn_a_participant(withdrawn_participant:, induction_coordinator:)
    partnership = Partnership.find_by(school: withdrawn_participant.school, cohort: withdrawn_participant.cohort)

    email = template_mail(
      PARTICIPANT_WITHDRAWN_BY_PROVIDER,
      to: induction_coordinator.user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: induction_coordinator.user.full_name,
        withdrawn_participant_name: withdrawn_participant.user.full_name,
        school: withdrawn_participant.school.name,
        delivery_partner: partnership&.delivery_partner_name || "No delivery partner",
        lead_provider: partnership&.lead_provider_name || "No lead provider",
      },
    )
    email
      .tag(:sit_fip_provider_has_withdrawn_a_participant)
      .associate_with(induction_coordinator, as: :induction_coordinator)
      .associate_with(withdrawn_participant, as: :participant_profile)
  end
end
