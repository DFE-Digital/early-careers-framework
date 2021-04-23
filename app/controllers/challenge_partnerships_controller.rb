# frozen_string_literal: true

class ChallengePartnershipsController < ApplicationController
  before_action :set_form, only: :create

  def show
    set_form
  rescue TokenExpiredError
    redirect_to link_expired_challenge_partnership_path
  rescue AlreadyChallengedError
    redirect_to already_challenged_challenge_partnership_path(school_name: @school_name)
  end

  def create
    render :show and return unless @challenge_partnership_form.valid?

    @challenge_partnership_form.challenge!
    redirect_to success_challenge_partnership_path
  end

  def link_expired; end

  def already_challenged
    @school_name = params[:school_name]
  end

  def success; end

private

  def set_form
    token = params[:token] || params.dig(:challenge_partnership_form, :token)
    notification_email = PartnershipNotificationEmail.find_by(token: token)
    raise ActionController::RoutingError, "Not Found" if notification_email.blank?
    raise TokenExpiredError if notification_email.token_expired?

    @partnership = notification_email.partnership
    @school_name = @partnership.school.name
    raise AlreadyChallengedError if @partnership.challenged?

    provider_name = @partnership.delivery_partner&.name || @partnership.lead_provider.name
    @challenge_partnership_form = ChallengePartnershipForm.new(
      school_name: @school_name,
      provider_name: provider_name,
      token: token,
      partnership: @partnership,
    )

    @challenge_partnership_form.assign_attributes(form_params)
  end

  def form_params
    return {} unless params.key?(:challenge_partnership_form)

    params.require(:challenge_partnership_form).permit(:challenge_reason, :token)
  end
end

class TokenExpiredError < StandardError; end

class AlreadyChallengedError < StandardError; end
