# frozen_string_literal: true

module AdminHelper
  def admin_edit_user_path(user)
    if user.lead_provider?
      edit_admin_lead_provider_user_path(user)
    elsif user.induction_coordinator?
      edit_admin_induction_coordinator_path(user)
    end
  end
end
