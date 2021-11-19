# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout "application"

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: I18n.t(:resource_not_found) }, status: :not_found }
      format.all { render status: :not_found, body: nil }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: { error: I18n.t(:internal_server_error) }, status: :internal_server_error }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render status: :unprocessable_entity }
      format.json { render json: { error: I18n.t(:unprocessable_entity) }, status: :unprocessable_entity }
    end
  end

  def forbidden
    respond_to do |format|
      format.html { render status: :forbidden }
      format.json { render json: { error: I18n.t(:forbidden) }, status: :forbidden }
    end
  end
end
