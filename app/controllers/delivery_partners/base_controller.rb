# frozen_string_literal: true

module DeliveryPartners
  class BaseController < ApplicationController
    include Pundit::Authorization

    before_action :authenticate_user!
    before_action :ensure_delivery_partner

    layout "delivery_partners"

  private

    def ensure_delivery_partner
      raise Pundit::NotAuthorizedError, I18n.t(:forbidden) unless current_user.delivery_partner?
    end
  end
end
