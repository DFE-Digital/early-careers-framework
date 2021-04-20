# frozen_string_literal: true

class PrivacyPoliciesController < ApplicationController
  skip_before_action :check_privacy_policy_accepted

  def show; end

  def update
    current_user.update!(privacy_policy_acceptance: {
      accepted_at: Time.zone.now,
      version: params[:pp_version],
    })
    redirect_to session.delete(:original_path)
  end
end
