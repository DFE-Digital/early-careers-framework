# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      notify_school_primary_contact
      sign_in(resource)
      @current_user = current_user
      render :confirmed
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end

private

  def notify_school_primary_contact
    return unless resource.induction_coordinator?

    school = resource.induction_coordinator_profile.schools.first

    if school.primary_contact_email != resource.email
      UserMailer.primary_contact_notification(resource, school).deliver_now
    end
  end
end
