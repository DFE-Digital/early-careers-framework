# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      render :confirmed
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end
end
