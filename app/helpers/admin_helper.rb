# frozen_string_literal: true

module AdminHelper
  def admin_edit_user_path(user)
    if user.lead_provider?
      edit_admin_lead_provider_user_path(user)
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

  def html_list(values)
    return nil if values.empty?

    tag.ul(class: %w[govuk-list]) { safe_join(values.map { |v| tag.li(v) }) }
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

  def admin_participant_header_and_title(full_name:, role:, section:)
    content_for(:title) { "#{full_name} - #{section}" }

    tag.h1 do
      safe_join([tag.span("#{full_name} (#{role.downcase})", class: "govuk-caption-m"), section])
    end
  end
end
