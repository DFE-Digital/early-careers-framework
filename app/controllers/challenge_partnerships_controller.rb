# frozen_string_literal: true

class ChallengePartnershipsController < ApplicationController
  def show
    set_partnership
  rescue TokenExpiredError
    redirect_to link_expired_challenge_partnership_path
  rescue AlreadyChallengedError
    redirect_to already_challenged_challenge_partnership_path(school_name: @school_name)
  end

  def link_expired; end

  def already_challenged
    @school_name = params[:school_name]
  end

private

  def set_partnership
    token = params[:token]
    notification_email = PartnershipNotificationEmail.find_by(token: token)
    raise ActionController::RoutingError, "Not Found" if notification_email.blank?
    raise TokenExpiredError if notification_email.token_expired?

    @partnership = notification_email.partnership
    @school_name = @partnership.school.name
    raise AlreadyChallengedError if @partnership.challenged?

    @provider_name = @partnership.delivery_partner&.name || @partnership.lead_provider.name
  end
end

class TokenExpiredError < StandardError; end

class AlreadyChallengedError < StandardError; end
