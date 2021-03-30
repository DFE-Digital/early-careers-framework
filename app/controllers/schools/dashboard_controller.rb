# frozen_string_literal: true

class Schools::DashboardController < Schools::BaseController
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def show; end
end
