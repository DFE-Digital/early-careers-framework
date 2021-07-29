# frozen_string_literal: true

class ChallengePartnershipsController < ApplicationController
  include Pundit
  before_action :authorize_partnership, only: %i[show create]
  before_action :set_form, only: %i[show create]

  def show; end

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

  def authorize_partnership
    @token = params[:token] || params.dig(:challenge_partnership_form, :token)
    partnership_id = params[:partnership] || params.dig(:challenge_partnership_form, :partnership)
    if @token.present?
      notification_email = PartnershipNotificationEmail.find_by(token: @token)
      raise ActionController::RoutingError, "Not Found" if notification_email.blank?

      @partnership = notification_email.partnership
    elsif partnership_id.present?
      @partnership = Partnership.find(partnership_id)
      authorize(@partnership, :update?)
    else
      raise ActionController::RoutingError, "Not Found"
    end
  end

  def set_form
    @school_name = @partnership.school.name
    redirect_to already_challenged_challenge_partnership_path(school_name: @school_name) and return if @partnership.challenged?

    redirect_to link_expired_challenge_partnership_path and return unless @partnership.in_challenge_window?

    @challenge_partnership_form = ChallengePartnershipForm.new(
      school_name: @school_name,
      lead_provider_name: @partnership.lead_provider.name,
      delivery_partner_name: @partnership.delivery_partner.name,
      token: @token,
      partnership_id: @partnership.id,
    )

    @challenge_partnership_form.assign_attributes(form_params)
  end

  def form_params
    return {} unless params.key?(:challenge_partnership_form)

    params.require(:challenge_partnership_form).permit(:challenge_reason, :token)
  end
end
