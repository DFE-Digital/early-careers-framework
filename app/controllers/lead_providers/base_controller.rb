# frozen_string_literal: true

module LeadProviders
  class BaseController < ApplicationController
    include Pundit

    before_action :authenticate_user!
    before_action :ensure_lead_provider_or_admin

    private

    def ensure_lead_provider_or_admin
      raise Pundit::NotAuthorizedError, "Forbidden" unless current_user&.admin? || current_user&.lead_provider?
    end

  end
end

