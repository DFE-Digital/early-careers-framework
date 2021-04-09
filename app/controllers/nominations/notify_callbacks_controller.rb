# frozen_string_literal: true

class Nominations::NotifyCallbacksController < ActionController::API
  def create
    email = NominationEmail.find_by(token: params[:reference])
    email.update!(notify_status: params[:status])

    head :no_content
  end
end
