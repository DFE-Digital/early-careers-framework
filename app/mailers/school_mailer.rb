# frozen_string_literal: true

class SchoolMailer < ApplicationMailer
  # replacement for the above template with dynamic academic year
  NOMINATION_EMAIL_WITH_ACADEMIC_YEAR_TEMPLATE = "bfc43b20-922f-4323-8775-a6e05f06e24a"
  NOMINATION_CONFIRMATION_EMAIL_TEMPLATE = "7935cf72-75e9-4d0d-a05f-6f2ccda2b398"
  SCHOOL_REQUESTED_SIGNIN_LINK_FROM_GIAS = "f2764570-ca3c-4e3b-97c3-251a853c9dde"
  SCHOOL_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE = "8cac177e-b094-4a00-9179-94fadde8ced0"
  COORDINATOR_PARTNERSHIP_NOTIFICATION_EMAIL_TEMPLATE = "076e8486-cbcc-44ee-8a6e-d2a721ee1460"
  # replacement for the above template with dynamic academic year
  COORDINATOR_PARTNERSHIP_NOTIFICATION_WITH_ACADEMIC_YEAR_EMAIL_TEMPLATE = "123eb3e6-401f-4c1d-b81e-113cb6580fc9"
  PARTICIPANT_WITHDRAWN_BY_PROVIDER = "29f94916-8c3a-4c5a-9e33-bdf3f5d7249a"
  REMIND_GIAS_CONTACT_TO_UPDATE_INDUCTION_TUTOR_DETAILS_TEMPLATE = "88cdad72-386c-40fb-be2e-11d4ae9dcdee"
  PILOT_CHASE_SIT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE = "87d4720b-9e3a-46d9-95de-493295dba1dc"
  PILOT_CHASE_GIAS_CONTACT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE = "ae925ff1-edc3-4d5c-a120-baa3a79c73af"
  LAUNCH_ASK_SIT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE = "1f796f27-9ba4-4705-a7c9-57462bd1e0b7"
  LAUNCH_ASK_GIAS_CONTACT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE = "f4dfee2a-2cc3-4d32-97f9-8adca41343bf"
  COHORTLESS_PILOT_2023_SURVEY_TEMPLATE = "5f6dc6bf-62c5-4cf1-8cc8-1440453f4a2d"
  REMIND_SIT_TO_ADD_PARTICIPANTS_TEMPLATE = "19b5a258-e615-4371-9e55-f9cc58187448"
  REMIND_SIT_TO_ASSIGN_MENTORS_TO_ECTS_TEMPLATE = "ae0b1c48-de11-4231-b394-0288bb779987"
  LAUNCH_ASK_GIAS_CONTACT_TO_VALIDATE_SIT_DETAILS_TEMPLATE = "1a8d24eb-cd08-4836-bfc2-3a9cf33de67e"
  SIT_NEEDS_TO_CHASE_PARTNERSHIP = "c640e594-21f6-4de3-be41-ebb74b2c8306"

  def ask_gias_contact_to_validate_sit_details
    school = params[:school]
    start_page_url = params[:start_page_url]
    nomination_url = params[:nomination_link]
    induction_coordinator = params[:induction_coordinator]

    email_address = school.primary_contact_email || school.secondary_contact_email

    template_mail(
      LAUNCH_ASK_GIAS_CONTACT_TO_VALIDATE_SIT_DETAILS_TEMPLATE,
      to: email_address,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        sit_name: induction_coordinator.user.full_name,
        sit_email_address: induction_coordinator.user.email,
        email_address:,
        start_page: start_page_url,
        nomination_link: nomination_url,
      },
    ).tag(:ask_gias_contact_if_sit_details_are_correct).associate_with(school, induction_coordinator)
  end

  def remind_sit_to_assign_mentors_to_ects_email
    induction_coordinator = params[:induction_coordinator]
    email_address = induction_coordinator.user.email
    name = induction_coordinator.user.full_name

    template_mail(
      REMIND_SIT_TO_ASSIGN_MENTORS_TO_ECTS_TEMPLATE,
      to: email_address,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name:,
        email_address:,
      },
    ).tag(:remind_sits_to_assign_mentors_to_ects).associate_with(induction_coordinator, as: :induction_coordinator_profile)
  end

  def remind_sit_to_add_ects_and_mentors_email
    induction_coordinator = params[:induction_coordinator]
    email_address = induction_coordinator.user.email
    name = induction_coordinator.user.full_name

    template_mail(
      REMIND_SIT_TO_ADD_PARTICIPANTS_TEMPLATE,
      to: email_address,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name:,
        email_address:,
      },
    ).tag(:remind_sits_to_add_ects_and_mentors).associate_with(induction_coordinator, as: :induction_coordinator_profile)
  end

  def cohortless_pilot_2023_survey_email
    sit_user = params[:sit_user]

    template_mail(
      COHORTLESS_PILOT_2023_SURVEY_TEMPLATE,
      to: sit_user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: sit_user.full_name,
      },
    ).tag(:cohortless_pilot_2023_survey).associate_with(sit_user.induction_coordinator_profile)
  end

  def nomination_email
    recipient = params[:recipient]
    school = params[:school]
    nomination_url = params[:nomination_url]
    expiry_date = params[:expiry_date]

    academic_year = if FeatureFlag.active?(:cohortless_dashboard, for: school)
                      Cohort.active_registration_cohort.description
                    else
                      Cohort.current.description
                    end

    template_mail(
      NOMINATION_EMAIL_WITH_ACADEMIC_YEAR_TEMPLATE,
      to: recipient,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        school_name: school.name,
        nomination_link: nomination_url,
        expiry_date:,
        academic_year:,
      },
    ).tag(:request_to_nominate_sit).associate_with(school)
  end

  # This email lets the GIAS contact at a school update their induction tutor
  def remind_to_update_school_induction_tutor_details
    school = params[:school]
    personalisation = params.slice(:nomination_link, :sit_name)

    template_mail(
      REMIND_GIAS_CONTACT_TO_UPDATE_INDUCTION_TUTOR_DETAILS_TEMPLATE,
      to: [school.primary_contact_email, school.secondary_contact_email].compact.uniq,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation:,
    ).tag(:remind_to_update_induction_tutor).associate_with(school)
  end

  # This email is sent to newly appointed SIT
  def nomination_confirmation_email
    sit_profile = params[:sit_profile]
    school = params[:school]
    start_url = params[:start_url]
    step_by_step_url = params[:step_by_step_url]
    sit_email_address = sit_profile.user.email

    template_mail(
      NOMINATION_CONFIRMATION_EMAIL_TEMPLATE,
      to: sit_email_address,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        email_address: sit_email_address,
        name: sit_profile.user.full_name,
        school_name: school.name,
        support_email: "continuing-professional-development@digital.education.gov.uk",
        how_to_manage_training: "https://www.gov.uk/guidance/how-to-manage-early-career-teacher-training",
        how_to_set_up_training: "https://www.gov.uk/guidance/how-to-set-up-training-for-early-career-teachers",
        start_page: start_url,
        subject: "Sign in to manage induction",
        step_by_step: step_by_step_url,
      },
    ).tag(:sit_nominated).associate_with(school, sit_profile)
  end

  # This email is sent when induction tutor to be changed
  def school_requested_signin_link_from_gias_email
    school = params[:school]
    nomination_link = params[:nomination_link]

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
  def school_partnership_notification_email
    recipient = params[:recipient]
    partnership = params[:partnership]
    challenge_url = params[:challenge_url]
    nominate_url = params[:nominate_url]

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
        challenge_deadline: partnership.challenge_deadline&.to_date&.to_fs(:govuk),
        subject: "FAO: NQT coordinator. Training provider confirmed.",
      },
    ).tag(:partnership_created, :request_to_nominate_sit).associate_with(partnership, partnership.school)
  end

  # This email is sent to the SIT of the school whe was reported to enter the partnership with lead provider.
  # If given school has no appointed SIT, the `school_partnership_notification_email` should be sent instead
  def coordinator_partnership_notification_email
    coordinator = params[:coordinator]
    partnership = params[:partnership]
    sign_in_url = params[:sign_in_url]
    challenge_url = params[:challenge_url]

    template_mail(
      COORDINATOR_PARTNERSHIP_NOTIFICATION_WITH_ACADEMIC_YEAR_EMAIL_TEMPLATE,
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
        academic_year: partnership.cohort.description,
        subject: "Training provider confirmed: add your ECTs and mentors",
      },
    ).tag(:partnership_created).associate_with(partnership, partnership.school)
  end

  def year2020_add_participants_confirmation
    template_mail(
      ADD_2020_PARTICIPANT_CONFIRMATION_TEMPLATE,
      to: params[:recipient],
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        subject: "2020 to 2021 NQTs cohort: support materials confirmation",
        school_name: params[:school_name],
        teacher_name_list: params[:teacher_name_list],
      },
    )
  end

  def fip_provider_has_withdrawn_a_participant
    withdrawn_participant = params[:withdrawn_participant]
    induction_coordinator = params[:induction_coordinator]
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

  # Pilot one-off mailers

  def pilot_chase_sit_to_report_school_training_details
    sit_user = params[:sit_user]
    nomination_link = params[:nomination_link]

    template_mail(
      PILOT_CHASE_SIT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE,
      to: sit_user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: sit_user.full_name,
        nomination_link:,
        email_address: sit_user.email,
      },
    ).tag(:pilot_chase_sit_to_report_school_training_details).associate_with(sit_user)
  end

  def pilot_chase_gias_contact_to_report_school_training_details
    school = params[:school]
    gias_contact_email = params[:gias_contact_email]
    opt_in_out_link = params[:nomination_link]

    template_mail(
      PILOT_CHASE_GIAS_CONTACT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE,
      to: gias_contact_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        opt_in_out_link:,
      },
    ).tag(:pilot_chase_gias_contact_to_report_school_training_details).associate_with(school)
  end

  def launch_ask_sit_to_report_school_training_details
    sit_user = params[:sit_user]
    nomination_link = params[:nomination_link]

    template_mail(
      LAUNCH_ASK_SIT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE,
      to: sit_user.email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        name: sit_user.full_name,
        nomination_link:,
      },
    ).tag(:launch_ask_sit_to_report_school_training_details).associate_with(sit_user.school, sit_user)
  end

  def launch_ask_gias_contact_to_report_school_training_details
    school = params[:school]
    gias_contact_email = params[:gias_contact_email]
    opt_in_out_link = params[:opt_in_out_link]

    template_mail(
      LAUNCH_ASK_GIAS_CONTACT_TO_REPORT_SCHOOL_TRAINING_DETAILS_TEMPLATE,
      to: gias_contact_email,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        opt_in_out_link:,
      },
    ).tag(:launch_ask_gias_contact_to_report_school_training_details).associate_with(school)
  end

  def sit_needs_to_chase_partnership
    induction_coordinator = params[:induction_coordinator]
    sit_name = induction_coordinator.user.full_name
    sit_email_address = induction_coordinator.user.email

    email = template_mail(
      SIT_NEEDS_TO_CHASE_PARTNERSHIP,
      to: sit_email_address,
      rails_mailer: mailer_name,
      rails_mail_template: action_name,
      personalisation: {
        SIT_name: sit_name,
        email_address: sit_email_address,
      },
    )
    email
      .tag(:sit_needs_to_chase_partnership)
      .associate_with(induction_coordinator, as: :induction_coordinator)
  end
end
