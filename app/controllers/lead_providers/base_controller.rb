# frozen_string_literal: true

module LeadProviders
  class BaseController < ApplicationController
    include Pundit::Authorization

    before_action :authenticate_user!
    before_action :ensure_lead_provider

  private

    def ensure_lead_provider
      return if current_user&.lead_provider?

      raise Pundit::NotAuthorizedError, I18n.t(:forbidden)
    end
  end
end
