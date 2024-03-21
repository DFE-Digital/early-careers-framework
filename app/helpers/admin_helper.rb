# frozen_string_literal: true

module AdminHelper
  def admin_edit_user_path(user)
    if user.lead_provider?
      edit_admin_lead_provider_lead_provider_user_path(user.lead_provider, user)
    elsif user.induction_coordinator?
      edit_admin_induction_coordinator_path(user)
    end
  end

  def all_emails_associated_with_a_user(user)
    ParticipantIdentity.where(user:).pluck(:email)
  end

  def on_admin_npq_application_page?
    request.path.starts_with?("/admin/npq/applications")
  end

  def html_list(values, bullets: false)
    return nil if values.empty?

    list_classes = class_names("govuk-list", "govuk-list--bullet" => bullets)

    tag.ul(class: list_classes) { safe_join(values.map { |v| tag.li(v) }) }
  end

  def induction_programme_friendly_name(name, short: false)
    long_names = {
      "full_induction_programme" => "Full induction programme",
      "core_induction_programme" => "Core induction programme",
      "design_our_own" => "Design our own",
      "school_funded_fip" => "School funded full induction programme",
    }.freeze

    short_names = {
      "full_induction_programme" => "FIP",
      "core_induction_programme" => "CIP",
      "design_our_own" => "Design our own",
      "school_funded_fip" => "School funded FIP",
    }.freeze

    short ? short_names.fetch(name) : long_names.fetch(name)
  end

  def format_address(*parts)
    return if parts.blank?

    safe_join(parts.compact_blank, tag.br)
  end

  def admin_participant_header_and_title(presenter:, section:)
    profile = presenter.participant_profile
    full_name = profile.full_name
    role = admin_participant_role_name(profile.class.name)
    trn = profile.teacher_profile.trn
    start_year = presenter.start_year

    visually_hidden = tag.span(" - #{section}", class: "govuk-visually-hidden")

    content_for(:title) { "#{full_name} - #{section}" }

    safe_join([
      tag.span(role, class: "govuk-caption-l"),
      tag.h1(class: "govuk-heading-l govuk-!-margin-bottom-4") { safe_join([full_name, visually_hidden]) },
      tag.p(class: "govuk-!-margin-top-1 govuk-!-margin-bottom-1") do
        safe_join(
          [
            tag.span("TRN: ", class: "govuk-body govuk-!-font-weight-bold"),
            trn,
          ],
        )
      end,
      tag.p(class: "govuk-!-margin-top-1 govuk-!-margin-bottom-3") do
        safe_join(
          [
            tag.span("Cohort: ", class: "govuk-body govuk-!-font-weight-bold"),
            start_year,
          ],
        )
      end,
    ])
  end

  def nomination_email_or_generate_link(school)
    nomination_email = school.nomination_emails.first

    if nomination_email.nil? || nomination_email.expired?
      govuk_link_to generate_link_admin_test_data_unclaimed_school_path(school) do
        %(Generate link <span class="govuk-visually-hidden">for #{school.name}</span>).html_safe
      end
    else
      govuk_link_to nomination_email.plain_nomination_url, nomination_email.plain_nomination_url
    end
  end

  def admin_participant_role_name(class_name)
    case class_name
    when "ParticipantProfile::Mentor" then "Mentor"
    when "ParticipantProfile::ECT" then "ECT"
    when "ParticipantProfile::NPQ" then "NPQ"
    else
      "unknown"
    end
  end

  def training_statuses
    [
      OpenStruct.new(id: "deferred", value: "Deferred"),
      OpenStruct.new(id: "withdrawn", value: "Withdrawn"),
    ]
  end

  def allowed_to_change_induction_status?(participant_presenter)
    policy(participant_presenter.participant_profile).edit_induction_status? &&
      %w[withdrawn leaving].include?(participant_presenter.relevant_induction_record&.induction_status)
  end

  def govuk_link_to_notify(text, template_id)
    template_url = "https://www.notifications.service.gov.uk/services/d1207ebf-ac0c-47b8-b1bf-16dc899e0923/templates/#{template_id}"

    govuk_link_to(text, template_url, target: "_blank")
  end
end
