# frozen_string_literal: true

module AppropriateBodies
  class BaseController < ApplicationController
    include Pundit::Authorization

    before_action :authenticate_user!
    before_action :ensure_appropriate_body
    before_action :set_appropriate_body

    layout "appropriate_bodies"

  private

    def ensure_appropriate_body
      raise Pundit::NotAuthorizedError, I18n.t(:forbidden) unless current_user.appropriate_body?
    end

    def set_appropriate_body
      return if params[:appropriate_body_id].blank?

      @appropriate_body = current_user.appropriate_bodies.find(params[:appropriate_body_id])
    end
  end
end
