# frozen_string_literal: true

class LeadProvider::BaseController < ApplicationController
  include Pundit

  before_action :authenticate_user!
  before_action :ensure_lead_provider_or_admin
  after_action :verify_authorized
  after_action :verify_policy_scoped

private

  def ensure_lead_provider_or_admin
    raise Pundit::NotAuthorizedError, "Forbidden" unless current_user&.admin? || current_user&.lead_provider?
  end
end
