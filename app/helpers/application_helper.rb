# frozen_string_literal: true

module ApplicationHelper
  def profile_dashboard_url(user)
    if user.admin?
      admin_suppliers_url
    elsif user.lead_provider?
      lead_provider_dashboard_url
    else
      dashboard_url
    end
  end
end
