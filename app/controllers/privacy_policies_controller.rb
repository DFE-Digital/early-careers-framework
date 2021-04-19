# frozen_string_literal: true

class PrivacyPoliciesController < ApplicationController
  skip_before_action :check_privacy_policy_accepted
  before_action :load_policy

  def show; end

  def update
    @policy.accept!(current_user)
    redirect_to session.delete(:original_path)
  end

private

  def load_policy
    @policy = PrivacyPolicy.current
  end
end
