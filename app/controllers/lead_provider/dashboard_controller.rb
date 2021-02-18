# frozen_string_literal: true

class LeadProvider::DashboardController < LeadProvider::BaseController
  def show
    skip_authorization
    skip_policy_scope

    @cohorts = @current_user.lead_provider.cohorts
  end
end
