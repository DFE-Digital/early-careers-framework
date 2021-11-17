# frozen_string_literal: true

class ChallengePartnershipsController < ApplicationController
  include Pundit
  include SchoolAccessTokenConsumer

  before_action :authorize_partnership, only: %i[show create]
  helper_method :partnership, :challenge_partnership_form

  def show; end

  def create
    render :show and return unless challenge_partnership_form.valid?

    challenge_partnership_form.challenge!
    redirect_to success_challenge_partnership_path
  end

  def link_expired; end

  def already_challenged
    @school_name = params[:school_name]
  end

  def success; end

private

  def authorize_partnership
    if access_token.present?
      if access_token.school != partnership.school || !access_token.permits?(:challenge_partnership)
        raise Pundit::NotAuthorizedError
      end
    else
      authorize(partnership, :update?)
    end

    if partnership.challenged?
      redirect_to already_challenged_challenge_partnership_path(school_name: partnership.school.name) and return
    end

    redirect_to link_expired_challenge_partnership_path unless partnership.in_challenge_window?
  end

  def form_params
    return {} unless params.key?(:challenge_partnership_form)

    params.require(:challenge_partnership_form).permit(:challenge_reason, :partnership_id)
  end

  def partnership
    challenge_partnership_form.partnership
  end

  def challenge_partnership_form
    @challenge_partnership_form ||= ChallengePartnershipForm.new(
      form_params.presence || { partnership_id: params[:partnership] },
    )
  end
end
