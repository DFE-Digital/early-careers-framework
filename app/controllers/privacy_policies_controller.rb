# frozen_string_literal: true

class PrivacyPoliciesController < ApplicationController
  skip_before_action :check_privacy_policy_accepted

  def show
    @policy = PrivacyPolicy.current
  end

  def update
    policy = PrivacyPolicy.find(params[:policy_id])
    policy.accept!(current_user)

    redirect_to session.delete(:original_path)
  end
end
