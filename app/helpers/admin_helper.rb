# frozen_string_literal: true

module AdminHelper
  def admin_edit_user_path(user)
    if user.lead_provider?
      edit_admin_lead_provider_user_path(user)
    elsif user.induction_coordinator?
      edit_admin_induction_coordinator_path(user)
    end
  end

  def all_emails_associated_with_a_user(induction_record)
    ParticipantIdentity.where(user: induction_record.participant_profile.user).pluck(:email)
  end

  def on_admin_npq_application_page?
    request.path.starts_with?("/admin/npq/applications")
  end

  def html_list(values)
    return nil if values.empty?

    tag.ul(class: %w[govuk-list]) { safe_join(values.map { |v| tag.li(v) }) }
  end
end
